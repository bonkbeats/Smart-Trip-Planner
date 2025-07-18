import 'package:isar/isar.dart';
import 'trip_item.dart';

part 'trip_day.g.dart';

@collection
class TripDayIsar {
  Id id = Isar.autoIncrement;

  late String date;
  late String summary;

  final items = IsarLinks<TripItemIsar>();
}
