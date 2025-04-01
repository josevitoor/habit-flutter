import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Map<String, dynamic>> _habits = [];

  final List<IconData> _icons = [
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.book,
    FontAwesomeIcons.mugHot,
    FontAwesomeIcons.bed,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.circle,
  ];

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

  Future<void> _toggleCompletion(int id, bool isCompleted) async {
    await HabitDatabase.instance.updateHabitCompletion(id, !isCompleted);
    _loadHabits();
  }

  Future<void> _deleteHabit(int id) async {
    await HabitDatabase.instance.deleteHabit(id);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final newHabit = await Navigator.pushNamed(context, '/addHabit');
              if (newHabit != null) _loadHabits();
            },
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          final IconData habitIcon = _icons[habit['icon'] ?? 5];
          final bool isCompleted = habit['isCompleted'] == 1;

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(habitIcon, color: Colors.white),
              title: Text(
                habit['name'],
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequência: ${habit['frequency']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Horário: ${habit['time'] ?? 'Não definido'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: isCompleted ? 1.0 : 0.0,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : Colors.red),
                  )
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/editHabit', arguments: habit);
                      _loadHabits();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteHabit(habit['id']),
                  ),
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) => _toggleCompletion(habit['id'], isCompleted),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}