import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recurring_checklist/models/checklist.dart';
import 'package:recurring_checklist/models/checklist_item.dart';
import 'package:recurring_checklist/providers/checklist_provider.dart';
import 'package:recurring_checklist/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ChecklistAdapter());
  Hive.registerAdapter(ChecklistItemAdapter());
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => ChecklistProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ChecklistProvider>().isDarkMode;
    
    return MaterialApp(
      title: 'Recurring Checklist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
