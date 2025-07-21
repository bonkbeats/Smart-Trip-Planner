import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smart_trip_planner/pinecone_service/embedding.dart';

final apiKey = dotenv.env['PINECONE_API_KEY']!;
final pineconeBaseUrl = dotenv.env['PINECONE_URI'];
const namespace = 'trip-plans';

final pineconeQueryUrl = Uri.parse('$pineconeBaseUrl/query');
final pineconeUpsertUrl = Uri.parse('$pineconeBaseUrl/vectors/upsert');

Future<void> saveContextToPinecone(String prompt, String responseText) async {
  try {
    final embedding = await generateEmbedding(prompt);
    final vector = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "values": embedding,
      "metadata": {"text": responseText},
    };

    final response = await http.post(
      pineconeUpsertUrl,
      headers: {'Api-Key': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "vectors": [vector],
        "namespace": namespace,
      }),
    );

    if (response.statusCode != 200) {
      print('❌ Upsert failed: ${response.statusCode} → ${response.body}');
    }
  } catch (e) {
    print('❌ Error in saveContextToPinecone: $e');
  }
}

Future<List<Map<String, dynamic>>> getTopEmbeddingMatchesWithScore(
  String query, {
  double minScore = 0.90,
}) async {
  final embedding = await generateEmbedding(query);

  final response = await http.post(
    pineconeQueryUrl,
    headers: {'Api-Key': apiKey, 'Content-Type': 'application/json'},
    body: jsonEncode({
      "vector": embedding,
      "topK": 1,
      "includeMetadata": true,
      "namespace": namespace,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final matches = data['matches'] as List<dynamic>;

    return matches
        .where((match) => (match['score'] ?? 0.0) >= minScore)
        .map(
          (match) => {
            "text": match['metadata']['text'] as String,
            "score": match['score'] as double,
          },
        )
        .toList();
  } else {
    print('❌ Pinecone query failed: ${response.statusCode} → ${response.body}');
    return [];
  }
}
