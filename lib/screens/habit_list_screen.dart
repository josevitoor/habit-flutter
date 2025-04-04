import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import '../models/habit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'category_habit_screen.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> _habits = [];

  final List<IconData> _allIcons = [
    FontAwesomeIcons.dumbbell, // Exercícios
    FontAwesomeIcons.bookOpen, // Estudos
    FontAwesomeIcons.briefcase, // Trabalho
    FontAwesomeIcons.gamepad, // Lazer
    FontAwesomeIcons.utensils, // Alimentação
    FontAwesomeIcons.circle, // Outros
  ];

  final Map<int, String> _categoryNames = {
    0: 'Exercícios',
    1: 'Estudos',
    2: 'Trabalho',
    3: 'Lazer',
    4: 'Alimentação',
    5: 'Outros',
  };

  final Map<int, Color> _categoryColors = {
    0: Colors.greenAccent.shade400, // Exercícios
    1: Colors.blueAccent.shade400, // Estudos
    2: Colors.orangeAccent.shade400, // Trabalho
    3: Colors.purpleAccent.shade400, // Lazer
    4: Colors.redAccent.shade400, // Alimentação
    5: Colors.grey.shade400, // Outros
  };

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await HabitDatabase.instance.fetchHabits();
    setState(() {
      _habits = habits;
    });
  }

  Map<int, List<Habit>> _groupHabitsByIcon() {
    final grouped = <int, List<Habit>>{};
    for (final habit in _habits) {
      final iconIndex = habit.iconIndex ?? 5;
      if (!grouped.containsKey(iconIndex)) {
        grouped[iconIndex] = [];
      }
      grouped[iconIndex]!.add(habit);
    }
    return grouped;
  }

  void _navigateToCategoryHabits(int iconIndex) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHabitScreen(
          iconIndex: iconIndex,
          iconData: _allIcons[iconIndex],
          categoryName: _categoryNames[iconIndex] ?? 'Categoria',
        ),
      ),
    );
    if (result != null) {
      _loadHabits();
    } else {
      _loadHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.black;
    final textColorPrimary = Colors.white;
    final textColorSecondary = Colors.white70;

    final groupedHabits = _groupHabitsByIcon();
    final uniqueIconIndices = groupedHabits.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Hábitos', style: TextStyle(color: textColorPrimary)),
        backgroundColor: backgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: textColorPrimary),
            onPressed: () async {
              final newHabit = await Navigator.pushNamed(context, '/addHabit');
              if (newHabit != null) _loadHabits();
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: ListView.builder(
        itemCount: uniqueIconIndices.length,
        itemBuilder: (context, index) {
          final iconIndex = uniqueIconIndices[index];
          final iconData = _allIcons[iconIndex];
          final categoryName = _categoryNames[iconIndex] ?? 'Categoria';
          final habitCount = groupedHabits[iconIndex]?.length ?? 0;
          final categoryColor = _categoryColors[iconIndex] ?? Colors.grey;

          return Card(
            color: categoryColor.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: categoryColor,
                child: Icon(
                  iconData,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              title: Text(
                categoryName,
                style: TextStyle(
                  color: textColorPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '$habitCount hábito(s)',
                style: TextStyle(color: textColorSecondary),
              ),
              onTap: () {
                _navigateToCategoryHabits(iconIndex);
              },
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: textColorSecondary,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}