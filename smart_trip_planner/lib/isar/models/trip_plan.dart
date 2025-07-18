import 'package:isar/isar.dart';
import 'trip_day.dart';

part 'trip_plan.g.dart';

@collection
class TripPlanIsar {
  Id id = Isar.autoIncrement;

  late String title;
  late String startDate;
  late String endDate;

  final days = IsarLinks<TripDayIsar>();
}
