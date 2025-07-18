import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_trip_planner/isar/models/trip_day.dart';
import 'package:smart_trip_planner/isar/models/trip_item.dart';
import 'package:smart_trip_planner/isar/models/trip_plan.dart';

import '../model/model.dart'; // your app model

late Isar isar;

Future<void> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([
    TripPlanIsarSchema,
    TripDayIsarSchema,
    TripItemIsarSchema,
  ], directory: dir.path);
}

Future<void> saveTripPlanToIsar(TripPlan tripPlan) async {
  final plan = TripPlanIsar()
    ..title = tripPlan.title
    ..startDate = tripPlan.startDate
    ..endDate = tripPlan.endDate;

  for (final day in tripPlan.days) {
    final isarDay = TripDayIsar()
      ..date = day.date
      ..summary = day.summary;

    for (final item in day.items) {
      final isarItem = TripItemIsar()
        ..time = item.time
        ..activity = item.activity
        ..location = item.location;

      await isar.writeTxn(() async {
        await isar.tripItemIsars.put(isarItem);
      });

      isarDay.items.add(isarItem);
    }

    await isar.writeTxn(() async {
      await isar.tripDayIsars.put(isarDay);
      await isarDay.items.save();
    });

    plan.days.add(isarDay);
  }

  await isar.writeTxn(() async {
    await isar.tripPlanIsars.put(plan);
    await plan.days.save();
  });
}

Future<List<TripPlanIsar>> getAllTripPlans() async {
  final plans = await isar.tripPlanIsars.where().findAll();

  for (final plan in plans) {
    await plan.days.load(); // Load linked days
    for (final day in plan.days) {
      await day.items.load(); // Load linked items for each day
    }
  }

  return plans;
}
