import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:smart_trip_planner/isar/isar_trip_service.dart';
import 'package:smart_trip_planner/isar/models/trip_day.dart';
import 'package:smart_trip_planner/isar/models/trip_item.dart';
// import 'package:smart_trip_planner/isar/models/trip_day.dart';
// import 'package:smart_trip_planner/isar/models/trip_item.dart';
import 'package:smart_trip_planner/isar/models/trip_plan.dart';

import 'screens/home.dart';

// Global isar instance
late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await initIsar(); // ⬅️ this

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trip Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const VisionScreen(), // or HomeScreen
    );
  }
}
