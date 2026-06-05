import 'package:ta_discipline/core/constants/goal_categories.dart';

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final GoalCategory category;
  final DateTime? deadline;
  final double progress;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.category = GoalCategory.other,
    this.deadline,
    this.progress = 0.0,
    this.status = GoalStatus.notStarted,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category.name,
        'deadline': deadline?.toIso8601String(),
        'progress': progress,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: GoalCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => GoalCategory.other,
        ),
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        status: GoalStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => GoalStatus.notStarted,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Goal copyWith({
    String? title,
    String? description,
    GoalCategory? category,
    DateTime? deadline,
    double? progress,
    GoalStatus? status,
  }) =>
      Goal(
        id: id,
        userId: userId,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        deadline: deadline ?? this.deadline,
        progress: progress ?? this.progress,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class SubTask {
  final String id;
  final String goalId;
  final String title;
  final bool completed;
  final int order;

  const SubTask({
    required this.id,
    required this.goalId,
    required this.title,
    this.completed = false,
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal_id': goalId,
        'title': title,
        'completed': completed,
        'order': order,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        goalId: json['goal_id'] as String,
        title: json['title'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
        order: (json['order'] as num?)?.toInt() ?? 0,
      );

  SubTask copyWith({String? title, bool? completed, int? order}) => SubTask(
        id: id,
        goalId: goalId,
        title: title ?? this.title,
        completed: completed ?? this.completed,
        order: order ?? this.order,
      );
}
