import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_planner/LLM/gemini.dart';
import 'package:smart_trip_planner/model/model.dart';

// Input, status, and response providers
final inputTextProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final replyProvider = StateProvider<String>((ref) => '');
final loadscreenProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

// This holds the decoded trip plan
final tripPlanProvider = StateProvider<TripPlan?>((ref) => null);

final generateItineraryProvider = Provider((ref) {
  return () async {
    ref.read(loadingProvider.notifier).state = true;
    ref.read(loadscreenProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final userPrompt = ref.read(inputTextProvider);

      final prompt =
          '''
Format your response strictly as JSON in the following schema:

{
  "title": "Trip title",
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "days": [
    {
      "date": "YYYY-MM-DD",
      "summary": "Summary of day",
      "items": [
        {
          "time": "HH:mm",
          "activity": "What the user will do",
          "location": "lat,long"
        }
      ]
    }
  ]
}

$userPrompt
''';

      final reply = await callGeminiAPI(prompt);

      // print("🌐 Gemini Raw Reply:\n$reply");

      // Try extracting JSON from messy replies
      final jsonStart = reply.indexOf('{');
      final jsonEnd = reply.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid response format from Gemini');
      }

      final cleanJsonString = reply.substring(jsonStart, jsonEnd + 1);
      final decodedJson = jsonDecode(cleanJsonString);

      print("✅ Decoded JSON: $decodedJson");

      final tripPlan = TripPlan.fromJson(decodedJson);

      ref.read(replyProvider.notifier).state = reply;
      ref.read(tripPlanProvider.notifier).state = tripPlan;
    } catch (e, st) {
      ref.read(errorProvider.notifier).state = 'Something went wrong: $e';
      // print('❌ Error: $e\n$st');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(loadscreenProvider.notifier).state = false;
    }
  };
});
