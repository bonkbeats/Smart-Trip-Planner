import '../model/model.dart'; // your app-level models
import '../isar/models/trip_plan.dart'; // your Isar models
import '../isar/models/trip_day.dart';
import '../isar/models/trip_item.dart';

TripPlanIsar toIsarTripPlan(TripPlan tripPlan) {
  final plan = TripPlanIsar()
    ..title = tripPlan.title
    ..startDate = tripPlan.startDate
    ..endDate = tripPlan.endDate;

  final isarDays = tripPlan.days.map((day) {
    final isarDay = TripDayIsar()
      ..date = day.date
      ..summary = day.summary;

    final isarItems = day.items.map((item) {
      return TripItemIsar()
        ..time = item.time
        ..activity = item.activity
        ..location = item.location;
    }).toList();

    isarDay.items.addAll(isarItems);
    return isarDay;
  }).toList();

  plan.days.addAll(isarDays);
  return plan;
}
