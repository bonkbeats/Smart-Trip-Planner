import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Use your Hugging Face token

final hfToken = 'Bearer ${dotenv.env['HF_API_KEY']}';

Future<List<double>> generateEmbedding(String text) async {
  final url = Uri.parse(
    'https://router.huggingface.co/hf-inference/models/'
    'sentence-transformers/all-mpnet-base-v2/pipeline/feature-extraction',
  );

  final resp = await http.post(
    url,
    headers: {'Authorization': hfToken, 'Content-Type': 'application/json'},
    body: jsonEncode({
      'inputs': [text],
    }),
  );

  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    final vec = (data[0] as List).map((v) => (v as num).toDouble()).toList();
    print('✅ Embedding length: ${vec.length}'); // Should print 768
    return vec;
  } else {
    throw Exception('Embedding failed: ${resp.statusCode} ${resp.body}');
  }
}
