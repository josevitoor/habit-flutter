import 'package:HabitTools/models/habit.dart';
import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class HabitFormScreen extends StatefulWidget {
  final Habit? habit;

  const HabitFormScreen({super.key, this.habit});

  @override
  _HabitFormScreenState createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _frequency = 'Diária';
  TimeOfDay? _selectedTime;
  bool _isCompleted = false;
  int _selectedIconIndex = 5;
  int? _habitId;

  final List<IconData> _icons = [
    FontAwesomeIcons.dumbbell,
    FontAwesomeIcons.bookOpen,
    FontAwesomeIcons.briefcase,
    FontAwesomeIcons.gamepad,
    FontAwesomeIcons.utensils,
    FontAwesomeIcons.circle,
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    if (widget.habit != null) {
      _habitId = widget.habit!.id;
      _nameController.text = widget.habit!.name;
      _frequency = widget.habit!.frequency;
      _selectedTime =
          widget.habit!.time != null
              ? _parseTime(widget.habit!.time!)
              : null;
      _isCompleted = widget.habit!.isCompleted == 1;
      _selectedIconIndex = widget.habit!.iconIndex ?? 5;
    }
  }

  Future<void> _initializeNotifications() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: _habitId,
        name: _nameController.text,
        frequency: _frequency,
        time: _selectedTime != null ? _selectedTime!.format(context) : null,
        isCompleted: _isCompleted,
        iconIndex: _selectedIconIndex,
      );

      if (_habitId == null) {
        await HabitDatabase.instance.insertHabit(habit);
      } else {
        await HabitDatabase.instance.updateHabit(habit);
      }
      if (habit.time != null) {
        scheduleNotification(habit.name, habit.time!);
      }
      Navigator.pop(context, habit);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue.shade300,
              secondary: Colors.grey.shade600,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.grey[900],
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white70,
              dialTextColor: Colors.white,
              entryModeIconColor: Colors.blue.shade300,
              helpTextStyle: const TextStyle(color: Colors.white70),
              inputDecorationTheme: const InputDecorationTheme(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade300,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> scheduleNotification(String habitName, String time) async {
    final scheduledTime = _parseTimeToDateTime(time);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'habit_notifications',
      'Lembretes de Hábitos',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Hora de completar um hábito!',
      'Está na hora de fazer: $habitName',
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exact,
      payload: 'habito:$habitName',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _parseTimeToDateTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      return scheduledTime.add(const Duration(days: 1));
    }
    return scheduledTime;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade300;
    final secondaryColor = Colors.grey.shade600;
    final backgroundColor = Colors.black;
    final textColorPrimary = Colors.white;
    final textColorSecondary = Colors.white70;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _habitId == null ? 'Novo Hábito' : 'Editar Hábito',
          style: TextStyle(color: textColorPrimary),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        backgroundColor: backgroundColor,
        elevation: 1,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Hábito',
                  labelStyle: TextStyle(color: textColorSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: textColorSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
                style: TextStyle(color: textColorPrimary),
                validator: (value) => value!.isEmpty ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                dropdownColor: backgroundColor,
                items:
                    ['Diária', 'Semanal', 'Mensal'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: textColorPrimary),
                        ),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _frequency = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Frequência',
                  labelStyle: TextStyle(color: textColorSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: textColorSecondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  icon: Icon(Icons.repeat, color: secondaryColor),
                ),
                style: TextStyle(color: textColorPrimary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.schedule, color: secondaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'Horário: Não definido'
                          : 'Horário: ${_selectedTime!.format(context)}',
                      style: TextStyle(color: textColorSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: Text(
                      'Selecionar Horário',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children:
                    _icons.asMap().entries.map((entry) {
                      final int idx = entry.key;
                      final IconData icon = entry.value;
                      String tooltipMessage = '';
                      switch (idx) {
                        case 0:
                          tooltipMessage = 'Exercício';
                          break;
                        case 1:
                          tooltipMessage = 'Estudos';
                          break;
                        case 2:
                          tooltipMessage = 'Trabalho';
                          break;
                        case 3:
                          tooltipMessage = 'Lazer';
                          break;
                        case 4:
                          tooltipMessage = 'Alimentação';
                          break;
                        case 5:
                          tooltipMessage = 'Outros';
                          break;
                      }
                      return Tooltip(
                        message: tooltipMessage,
                        preferBelow: false,
                        decoration: BoxDecoration(
                          color: Colors.grey[800]!.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        child: IconButton(
                          icon: Icon(
                            icon,
                            color:
                                _selectedIconIndex == idx
                                    ? primaryColor
                                    : textColorSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIconIndex = idx;
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(
                  'Marcar como cumprido',
                  style: TextStyle(color: textColorPrimary),
                ),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
                activeColor: Colors.green.shade300,
                checkColor: textColorPrimary,
                tileColor: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: textColorPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Text('Salvar', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
