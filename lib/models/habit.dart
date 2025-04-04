class Habit {
  int? id;
  String name;
  String frequency;
  String? time;
  bool isCompleted;
  int iconIndex;

  Habit({
    this.id,
    required this.name,
    required this.frequency,
    this.time,
    this.isCompleted = false,
    required this.iconIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'icon': iconIndex,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      frequency: map['frequency'],
      time: map['time'],
      isCompleted: map['isCompleted'] == 1,
      iconIndex: map['icon'],
    );
  }
}