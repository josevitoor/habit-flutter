import 'package:flutter/material.dart';
import 'screens/habit_list_screen.dart';
import 'screens/habit_form_screen.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acompanhamento de Hábitos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HabitListScreen(),
        '/addHabit': (context) => const HabitFormScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/editHabit') {
          final habit = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HabitFormScreen(habit: habit),
          );
        }
        return null;
      },
    );
  }
}
