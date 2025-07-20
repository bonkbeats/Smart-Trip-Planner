import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_planner/LLM/gemini.dart';
import 'package:smart_trip_planner/model/model.dart';
import 'package:smart_trip_planner/pinecone_service/pine_service.dart';

// Input, status, and response providers
final inputTextProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final replyProvider = StateProvider<String>((ref) => '');
final loadscreenProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);
final isFollowUpProvider = StateProvider<bool>((ref) => false);
final tripPlanProvider = StateProvider<TripPlan?>((ref) => null);

// Provider that handles the trip plan generation
final generateItineraryProvider = Provider((ref) {
  return () async {
    ref.read(loadingProvider.notifier).state = true;
    ref.read(loadscreenProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final userPrompt = ref.read(inputTextProvider);
      final isFollowUp = ref.read(isFollowUpProvider);
      final previousReply = ref.read(replyProvider);

      String prompt = '''
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
''';

      // Only use Pinecone for the **initial** (non-follow-up) query
      if (!isFollowUp) {
        final similarResponses = await getTopMatches(userPrompt);

        for (final reusedReply in similarResponses) {
          if (reusedReply.contains('{')) {
            final jsonStart = reusedReply.indexOf('{');
            final jsonEnd = reusedReply.lastIndexOf('}');
            if (jsonStart != -1 && jsonEnd > jsonStart) {
              final cleanJson = reusedReply.substring(jsonStart, jsonEnd + 1);
              final decoded = jsonDecode(cleanJson);
              final tripPlan = TripPlan.fromJson(decoded);

              ref.read(replyProvider.notifier).state = reusedReply;
              ref.read(tripPlanProvider.notifier).state = tripPlan;
              print("✅ Reused high-score Pinecone match.");
              return;
            }
          }
        }

        if (similarResponses.isNotEmpty) {
          prompt += "\nHere are some similar past trip plans:\n";
          for (var i = 0; i < similarResponses.length; i++) {
            prompt += "Plan ${i + 1}:\n${similarResponses[i]}\n\n";
          }
        }

        prompt += "\nUser says:\n$userPrompt";
      } else {
        // For follow-ups, use only previous reply as context
        prompt += "\nPrevious plan:\n$previousReply\n\nUser says:\n$userPrompt";
      }

      print("📤 Prompt sent to Gemini:\n$prompt");

      final reply = await callGeminiAPI(prompt);
      print("🤖 Gemini reply:\n$reply");

      final jsonStart = reply.indexOf('{');
      final jsonEnd = reply.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        throw Exception('Invalid JSON response from Gemini');
      }

      final cleanJson = reply.substring(jsonStart, jsonEnd + 1);
      final decoded = jsonDecode(cleanJson);
      final tripPlan = TripPlan.fromJson(decoded);

      ref.read(replyProvider.notifier).state = reply;
      ref.read(tripPlanProvider.notifier).state = tripPlan;

      // Save to Pinecone only for non-follow-up prompts
      if (!isFollowUp) {
        await saveContextToPinecone(userPrompt, reply);
        print("✅ Saved to Pinecone");
      }
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Something went wrong: $e';
      print('❌ Error: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(loadscreenProvider.notifier).state = false;
    }
  };
});
