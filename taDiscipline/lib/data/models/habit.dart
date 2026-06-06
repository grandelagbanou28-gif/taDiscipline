import 'package:apex/core/constants/goal_categories.dart';

class Habit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitFrequency frequency;
  final int target;
  final String? color;
  final String? icon;
  final bool isPositive;
  final int cycleInterval;
  final String cycleUnit;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.frequency = HabitFrequency.daily,
    this.target = 1,
    this.color,
    this.icon,
    this.isPositive = true,
    this.cycleInterval = 1,
    this.cycleUnit = 'day',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'frequency': frequency.name,
        'target': target,
        'color': color,
        'icon': icon,
        'is_positive': isPositive,
        'cycle_interval': cycleInterval,
        'cycle_unit': cycleUnit,
        'created_at': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        frequency: HabitFrequency.values.firstWhere(
          (f) => f.name == json['frequency'],
          orElse: () => HabitFrequency.daily,
        ),
        target: (json['target'] as num?)?.toInt() ?? 1,
        color: json['color'] as String?,
        icon: json['icon'] as String?,
        isPositive: json['is_positive'] as bool? ?? true,
        cycleInterval: (json['cycle_interval'] as num?)?.toInt() ?? 1,
        cycleUnit: json['cycle_unit'] as String? ?? 'day',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool isDueToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final daysSince = today.difference(start).inDays;

    switch (cycleUnit) {
      case 'day':
        return daysSince % cycleInterval == 0;
      case 'week':
        return daysSince % (cycleInterval * 7) == 0;
      case 'month':
        final monthsSince =
            (now.year - createdAt.year) * 12 + (now.month - createdAt.month);
        return monthsSince % cycleInterval == 0;
      default:
        return daysSince % cycleInterval == 0;
    }
  }

  Habit copyWith({
    String? name,
    String? description,
    HabitFrequency? frequency,
    int? target,
    String? color,
    String? icon,
    bool? isPositive,
    int? cycleInterval,
    String? cycleUnit,
  }) =>
      Habit(
        id: id,
        userId: userId,
        name: name ?? this.name,
        description: description ?? this.description,
        frequency: frequency ?? this.frequency,
        target: target ?? this.target,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        isPositive: isPositive ?? this.isPositive,
        cycleInterval: cycleInterval ?? this.cycleInterval,
        cycleUnit: cycleUnit ?? this.cycleUnit,
        createdAt: createdAt,
      );
}

class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final double value;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.value = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_id': habitId,
        'date': date.toIso8601String(),
        'completed': completed,
        'value': value,
      };

  factory HabitLog.fromJson(Map<String, dynamic> json) => HabitLog(
        id: json['id'] as String,
        habitId: json['habit_id'] as String,
        date: DateTime.parse(json['date'] as String),
        completed: json['completed'] as bool? ?? false,
        value: (json['value'] as num?)?.toDouble() ?? 1.0,
      );

  HabitLog copyWith({bool? completed, double? value}) => HabitLog(
        id: id,
        habitId: habitId,
        date: date,
        completed: completed ?? this.completed,
        value: value ?? this.value,
      );
}
