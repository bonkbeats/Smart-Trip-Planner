import 'package:flutter/material.dart';
import '../isar/models/trip_plan.dart';
import '../isar/isar_trip_service.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  late Future<List<TripPlanIsar>> _tripPlansFuture;

  @override
  void initState() {
    super.initState();
    _tripPlansFuture = getAllTripPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Trips")),
      body: FutureBuilder<List<TripPlanIsar>>(
        future: _tripPlansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No saved trips found."));
          }

          final trips = snapshot.data!;
          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];

              return ExpansionTile(
                title: Text(trip.title),
                subtitle: Text("${trip.startDate} to ${trip.endDate}"),
                children: trip.days.map((day) {
                  return ExpansionTile(
                    title: Text("Date: ${day.date}"),
                    subtitle: Text(day.summary),
                    children: day.items.map((item) {
                      return ListTile(
                        title: Text(item.activity),
                        subtitle: Text("${item.time} @ ${item.location}"),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
