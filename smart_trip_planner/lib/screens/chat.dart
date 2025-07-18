import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_trip_planner/reiverpod.dart/gemini_reiverprovider.dart';

import 'package:smart_trip_planner/utils/maps.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputText = ref.watch(inputTextProvider);
    final loading = ref.watch(loadingProvider);
    final controller = TextEditingController();
    final tripPlan = ref.watch(tripPlanProvider);

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
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : tripPlan == null
                      ? const Text("No valid data available.")
                      : Column(
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
                            Text(
                              tripPlan.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "From ${tripPlan.startDate} to ${tripPlan.endDate}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: tripPlan.days.length,
                                itemBuilder: (context, index) {
                                  final day = tripPlan.days[index];
                                  final coordinates = day.items
                                      .map((item) => item.location)
                                      .where(
                                        (loc) =>
                                            loc.contains(',') &&
                                            double.tryParse(
                                                  loc.split(',').first,
                                                ) !=
                                                null,
                                      )
                                      .toList();

                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Row with date and map icon
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Date: ${day.date}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (coordinates.length >= 2)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.map_outlined,
                                                    color: Colors.teal,
                                                  ),
                                                  tooltip: "View route on map",
                                                  onPressed: () {
                                                    final mapUrl =
                                                        "https://www.google.com/maps/dir/?api=1&travelmode=walking&waypoints=${coordinates.join('|')}";
                                                    openMapUrl(mapUrl);
                                                  },
                                                ),
                                            ],
                                          ),
                                          Text(day.summary),
                                          const SizedBox(height: 8),
                                          ...day.items.map((item) {
                                            return GestureDetector(
                                              onTap: () {
                                                openMap(item.location);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      size: 18,
                                                      color: Colors.teal,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        "${item.time} - ${item.activity}",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.blue,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
