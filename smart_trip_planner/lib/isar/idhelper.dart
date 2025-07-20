import 'package:isar/isar.dart';
import 'package:smart_trip_planner/isar/models/trip_plan.dart';
import 'package:smart_trip_planner/main.dart';
import 'package:smart_trip_planner/model/model.dart';

Future<List<TripPlan>> getTripPlansFromIsar() async {
  final isarPlans = await isar.tripPlanIsars.where().findAll();

  final List<TripPlan> tripPlans = [];

  for (final isarPlan in isarPlans) {
    await isarPlan.days.load(); // Load linked days

    final List<TripDay> tripDays = [];

    for (final isarDay in isarPlan.days) {
      await isarDay.items.load(); // Load linked items

      final List<TripItem> tripItems = isarDay.items.map((isarItem) {
        return TripItem(
          time: isarItem.time,
          activity: isarItem.activity,
          location: isarItem.location,
        );
      }).toList();

      tripDays.add(
        TripDay(date: isarDay.date, summary: isarDay.summary, items: tripItems),
      );
    }

    tripPlans.add(
      TripPlan(
        title: isarPlan.title,
        startDate: isarPlan.startDate,
        endDate: isarPlan.endDate,
        days: tripDays,
      ),
    );
  }

  return tripPlans;
}
