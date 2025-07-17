import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_trip_planner/reiverpod.dart/gemini_reiverprovider.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputText = ref.watch(inputTextProvider);
    final loading = ref.watch(loadingProvider);
    final reply = ref.watch(replyProvider);
    final controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.teal),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You:\n$inputText\n',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Divider(),
                        reply.isEmpty && loading
                            ? const Center(child: CircularProgressIndicator())
                            : Text(
                                "Gemini:\n$reply",
                                style: const TextStyle(fontSize: 16),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Continue the conversation...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  loading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.teal),
                          onPressed: () async {
                            final newInput = controller.text.trim();
                            if (newInput.isNotEmpty) {
                              ref.read(inputTextProvider.notifier).state =
                                  newInput;
                              controller.clear();
                              await ref.read(generateItineraryProvider)();
                            }
                          },
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
