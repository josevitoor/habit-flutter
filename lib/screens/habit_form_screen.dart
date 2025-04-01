import 'package:flutter/material.dart';
import '../database/habit_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HabitFormScreen extends StatefulWidget {
  final Map<String, dynamic>? habit;
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
    FontAwesomeIcons.book,
    FontAwesomeIcons.mugHot,
    FontAwesomeIcons.bed,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.circle,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _habitId = widget.habit!['id'];
      _nameController.text = widget.habit!['name'];
      _frequency = widget.habit!['frequency'];
      _selectedTime = widget.habit!['time'] != null ? _parseTime(widget.habit!['time']) : null;
      _isCompleted = widget.habit!['isCompleted'] == 1;
      _selectedIconIndex = widget.habit!['icon'] ?? 5;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = {
        'id': _habitId,
        'name': _nameController.text,
        'frequency': _frequency,
        'time': _selectedTime != null ? _selectedTime!.format(context) : null,
        'isCompleted': _isCompleted ? 1 : 0,
        'icon': _selectedIconIndex,
      };
      if (_habitId == null) {
        await HabitDatabase.instance.insertHabit(habit);
      } else {
        await HabitDatabase.instance.updateHabit(habit);
      }
      Navigator.pop(context, habit);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_habitId == null ? 'Novo Hábito' : 'Editar Hábito'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hábito',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                dropdownColor: Colors.black,
                items: ['Diária', 'Semanal', 'Mensal'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _frequency = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Frequência',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _selectedTime == null ? 'Horário: Não definido' : 'Horário: ${_selectedTime!.format(context)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Selecionar Horário', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: _icons.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final IconData icon = entry.value;
                  return IconButton(
                    icon: Icon(icon, color: _selectedIconIndex == idx ? Colors.blue : Colors.white70),
                    onPressed: () {
                      setState(() {
                        _selectedIconIndex = idx;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Marcar como cumprido', style: TextStyle(color: Colors.white)),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value ?? false;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
