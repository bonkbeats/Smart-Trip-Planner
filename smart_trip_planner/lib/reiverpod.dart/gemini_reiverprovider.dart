import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_planner/LLM/gemini.dart';

final inputTextProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final replyProvider = StateProvider<String>((ref) => '');
final loadscreenProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

final generateItineraryProvider = Provider((ref) {
  return () async {
    ref.read(loadingProvider.notifier).state = true;
    ref.read(loadscreenProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final userPrompt = ref.read(inputTextProvider);

      final prompt =
          '''
 Format your response as JSON in the following schema:

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

      ref.read(replyProvider.notifier).state = reply;
    } catch (e) {
      ref.read(errorProvider.notifier).state = 'Something went wrong: $e';
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(loadscreenProvider.notifier).state = false;
    }
  };
});
