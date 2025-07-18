import 'package:isar/isar.dart';

part 'trip_item.g.dart';

@collection
class TripItemIsar {
  Id id = Isar.autoIncrement;

  late String time;
  late String activity;
  late String location;
}
