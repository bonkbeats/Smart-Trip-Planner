import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../isar/models/trip_plan.dart';
import '../isar/isar_trip_service.dart';
import '../reiverpod.dart/gemini_reiverprovider.dart';
import 'chat.dart';

class VisionScreen extends ConsumerStatefulWidget {
  const VisionScreen({super.key});

  @override
  ConsumerState<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends ConsumerState<VisionScreen> {
  late Future<List<TripPlanIsar>> _tripPlansFuture;

  @override
  void initState() {
    super.initState();
    _tripPlansFuture = getAllTripPlans();
  }

  @override
  Widget build(BuildContext context) {
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
                children: [Text.rich(TextSpan(children: [
                       
                      ],
                    ))],
              ),
              const SizedBox(height: 32),
              const Text(
                "What’s your vision\nfor this trip?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    ref.read(inputTextProvider.notifier).state = value;
                    ref.read(isFollowUpProvider.notifier).state = false;
                  },

                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration.collapsed(
                    hintText: "Describe your trip idea...",
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    // final previousReply = ref.read(replyProvider);
                    // final isFollowUp = previousReply.isNotEmpty;
                    ref.read(isFollowUpProvider.notifier).state = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );

                    Future.delayed(const Duration(milliseconds: 100), () {
                      ref.read(generateItineraryProvider)();
                    });
                  },
                  child: const Text(
                    "Create My Itinerary",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// SAVED TRIPS BELOW
              const Text(
                "Saved Trips",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<TripPlanIsar>>(
                  future: _tripPlansFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error loading trips: ${snapshot.error}"),
                      );
                    }

                    final trips = snapshot.data ?? [];

                    if (trips.isEmpty) {
                      return const Center(child: Text("No saved trips."));
                    }

                    return ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return Card(
                          child: ListTile(
                            title: Text(trip.title),
                            subtitle: Text(
                              "${trip.startDate} to ${trip.endDate}",
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(trip.title),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: trip.days.map((day) {
                                        return ExpansionTile(
                                          title: Text("📅 ${day.date}"),
                                          subtitle: Text(day.summary),
                                          children: day.items.map((item) {
                                            return ListTile(
                                              title: Text(item.activity),
                                              subtitle: Text(
                                                "${item.time} at ${item.location}",
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
