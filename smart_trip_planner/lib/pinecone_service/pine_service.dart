import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smart_trip_planner/pinecone_service/embedding.dart'; // Your embedding generator

// Your Pinecone API setup
final apiKey = dotenv.env['PINECONE_API_KEY']!;
final pineconeBaseUrl = dotenv.env['PINECONE_URI'];
const indexName = 'your-index-name'; // Replace with actual index name
const namespace = 'trip-plans'; // Optional: namespace grouping vectors

final pineconeQueryUrl = Uri.parse('$pineconeBaseUrl/query');
final pineconeUpsertUrl = Uri.parse('$pineconeBaseUrl/vectors/upsert');

// Set similarity score threshold (1.0 = perfect match)
const similarityThreshold = 0.95;

/// Queries Pinecone for the most relevant match to the given prompt.
/// If a match with score >= threshold is found, returns it; else returns null.
Future<String?> getBestMatchedResponse(String query) async {
  try {
    final embedding = await generateEmbedding(query);

    final response = await http.post(
      pineconeQueryUrl,
      headers: {'Api-Key': apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode({
        "vector": embedding,
        "topK": 1, // Only need the best match
        "includeMetadata": true,
        "includeValues": false,
        "namespace": namespace,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final matches = data['matches'] as List<dynamic>?;

      if (matches != null && matches.isNotEmpty) {
        final bestMatch = matches.first;
        final score = bestMatch['score'] ?? 0.0;
        final metadata = bestMatch['metadata'] ?? {};

        if (score >= similarityThreshold) {
          return metadata['text'] as String?;
        }
      }
    } else {
      print(
        '❌ Pinecone query failed: ${response.statusCode} → ${response.body}',
      );
    }
  } catch (e) {
    print('❌ Error in getBestMatchedResponse: $e');
  }

  return null;
}

/// Saves a prompt-response pair as a new vector in Pinecone for future matching.
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

Future<List<String>> getTopMatches(
  String query, {
  double threshold = 0.90,
}) async {
  final embedding = await generateEmbedding(query);

  final response = await http.post(
    pineconeQueryUrl,
    headers: {'Api-Key': apiKey, 'Content-Type': 'application/json'},
    body: jsonEncode({
      "vector": embedding,
      "topK": 5,
      "includeMetadata": true,
      "namespace": namespace,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final matches = data['matches'] as List<dynamic>;

    return matches
        .where((match) => (match['score'] ?? 0.0) >= threshold)
        .map((match) => match['metadata']['text'] as String)
        .toList();
  } else {
    print('❌ Pinecone query failed: ${response.statusCode} → ${response.body}');
    return [];
  }
}
