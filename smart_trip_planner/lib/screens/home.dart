import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_planner/reiverpod.dart/gemini_reiverprovider.dart';
import 'package:smart_trip_planner/screens/chat.dart';

class VisionScreen extends ConsumerWidget {
  const VisionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputText = ref.watch(inputTextProvider);
    final controller = TextEditingController(text: inputText)
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: inputText.length),
      );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hey Shubham ',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WidgetSpan(
                          child: Text('👋', style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text('S', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                "What’s your vision\nfor this trip?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: (value) =>
                        ref.read(inputTextProvider.notifier).state = value,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration.collapsed(
                      hintText: "Describe your trip idea...",
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Don't wait here – just navigate
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );

                    // Start generation after screen transition
                    Future.delayed(Duration(milliseconds: 100), () {
                      ref.read(generateItineraryProvider)();
                    });
                  },

                  child: const Text(
                    "Create My Itinerary",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
