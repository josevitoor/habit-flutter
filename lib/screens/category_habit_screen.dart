import 'package:HabitTools/models/habit.dart';
import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CategoryHabitScreen extends StatefulWidget {
  final int iconIndex;
  final IconData iconData;
  final String categoryName;

  const CategoryHabitScreen({
    super.key,
    required this.iconIndex,
    required this.iconData,
    required this.categoryName,
  });

  @override
  _CategoryHabitScreenState createState() => _CategoryHabitScreenState();
}

class _CategoryHabitScreenState extends State<CategoryHabitScreen> {
  List<Habit> _categoryHabits = [];
  double _completionPercentage = 0.0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCategoryHabits();
  }

  Future<void> _loadCategoryHabits() async {
    final habits = await HabitDatabase.instance.fetchHabitsByIcon(
      widget.iconIndex,
    );
    setState(() {
      _categoryHabits = habits;
      _calculateCompletionPercentage();
    });
  }

  void _calculateCompletionPercentage() {
    if (_categoryHabits.isEmpty) {
      _completionPercentage = 0.0;
      _completedCount = 0;
      return;
    }
    _completedCount =
        _categoryHabits.where((habit) => habit.isCompleted).length;
    _completionPercentage = _completedCount / _categoryHabits.length;
  }

  Future<void> _toggleCompletion(int id, bool isCompleted) async {
    await HabitDatabase.instance.updateHabitCompletion(id, isCompleted);
    _loadCategoryHabits();
  }

  Future<void> _deleteHabit(int id) async {
    await HabitDatabase.instance.deleteHabit(id);
    _loadCategoryHabits();
  }

  final Map<int, Color> _categoryColors = {
    0: Colors.greenAccent.shade400, // Exercícios
    1: Colors.blueAccent.shade400, // Estudos
    2: Colors.orangeAccent.shade400, // Trabalho
    3: Colors.purpleAccent.shade400, // Lazer
    4: Colors.redAccent.shade400, // Alimentação
    5: Colors.grey.shade400, // Outros
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade300;
    final backgroundColor = Colors.grey[900]!;
    final textColorPrimary = Colors.white;
    final textColorSecondary = Colors.white70;
    final colorCompleted = Colors.greenAccent.shade400;
    final colorNotCompleted = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(color: textColorPrimary),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 20.0,
              right: 20.0,
              bottom: 10.0,
            ),
            child: Text(
              'Progresso de ${widget.categoryName}',
              style: TextStyle(color: textColorSecondary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 12.0,
              percent: _completionPercentage,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_completionPercentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                  ),
                  Text(
                    '$_completedCount / ${_categoryHabits.length} hábitos',
                    style: TextStyle(color: textColorSecondary, fontSize: 14),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey[800]!,
              progressColor: primaryColor,
              animation: true,
            ),
          ),
          Expanded(
            child:
                _categoryHabits.isEmpty
                    ? Center(
                      child: Text(
                        'Nenhum hábito em ${widget.categoryName}.',
                        style: TextStyle(
                          color: textColorSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _categoryHabits.length,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemBuilder: (context, index) {
                        final habit = _categoryHabits[index];
                        final bool isCompleted = habit.isCompleted;
                        final textColor =
                            isCompleted ? Colors.grey[600] : textColorPrimary;
                        final secondaryTextColor =
                            isCompleted ? Colors.grey[700] : Colors.grey;
                        final categoryColor = _categoryColors[widget.iconIndex] ?? Colors.grey;

                        return Card(
                          color:
                              isCompleted ? Colors.grey[850] : categoryColor.withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  widget.iconData,
                                  color:
                                      isCompleted
                                          ? colorCompleted
                                          : colorNotCompleted,
                                  size: 30,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            'Frequência: ${habit.frequency}',
                                            style: TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (habit.time != null)
                                            Text(
                                              '(${habit.time})',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (value) {
                                    if (value != null) {
                                      _toggleCompletion(habit.id ?? 0, value);
                                    }
                                  },
                                  activeColor: primaryColor,
                                  checkColor: textColorPrimary,
                                ),
                                PopupMenuButton<String>(
                                  color: Colors.grey[850],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        '/editHabit',
                                        arguments: habit,
                                      ).then((_) => _loadCategoryHabits());
                                    } else if (value == 'delete') {
                                      _deleteHabit(habit.id ?? 0);
                                    }
                                  },
                                  itemBuilder:
                                      (
                                        BuildContext context,
                                      ) => <PopupMenuEntry<String>>[
                                        PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text(
                                            'Editar',
                                            style: TextStyle(color: textColor),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text(
                                            'Excluir',
                                            style: TextStyle(
                                              color: Colors.redAccent.shade400,
                                            ),
                                          ),
                                        ),
                                      ],
                                  child: Icon(
                                    Icons.more_vert,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
