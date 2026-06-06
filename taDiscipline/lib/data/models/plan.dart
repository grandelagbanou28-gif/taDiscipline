import 'package:apex/core/constants/goal_categories.dart';

class Plan {
  final String id;
  final String userId;
  final DateTime date;
  final List<PlanTask> tasks;
  final PlanType type;
  final DateTime createdAt;

  const Plan({
    required this.id,
    required this.userId,
    required this.date,
    this.tasks = const [],
    this.type = PlanType.weekly,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'type': type.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        tasks: (json['tasks'] as List<dynamic>?)
                ?.map((t) => PlanTask.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [],
        type: PlanType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => PlanType.weekly,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Plan copyWith({List<PlanTask>? tasks, PlanType? type}) => Plan(
        id: id,
        userId: userId,
        date: date,
        tasks: tasks ?? this.tasks,
        type: type ?? this.type,
        createdAt: createdAt,
      );
}

class PlanTask {
  final String id;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool completed;
  final String? goalId;
  final int order;

  const PlanTask({
    required this.id,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.completed = false,
    this.goalId,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'start_time': startTime?.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'completed': completed,
        'goal_id': goalId,
        'order': order,
      };

  factory PlanTask.fromJson(Map<String, dynamic> json) => PlanTask(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        startTime: json['start_time'] != null
            ? DateTime.parse(json['start_time'] as String)
            : null,
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
        completed: json['completed'] as bool? ?? false,
        goalId: json['goal_id'] as String?,
        order: (json['order'] as num?)?.toInt() ?? 0,
      );

  PlanTask copyWith({
    String? title,
    bool? completed,
    DateTime? startTime,
    DateTime? endTime,
    int? order,
  }) =>
      PlanTask(
        id: id,
        title: title ?? this.title,
        description: description,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        completed: completed ?? this.completed,
        goalId: goalId,
        order: order ?? this.order,
      );
}
