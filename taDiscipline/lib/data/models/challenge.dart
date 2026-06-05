class Challenge {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String goalType;
  final int goalTarget;
  final bool isPublic;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Challenge({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description = '',
    this.category = 'other',
    required this.startDate,
    required this.endDate,
    this.goalType = 'sessions',
    this.goalTarget = 0,
    this.isPublic = true,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator_id': creatorId,
        'title': title,
        'description': description,
        'category': category,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'goal_type': goalType,
        'goal_target': goalTarget,
        'is_public': isPublic,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'other',
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        goalType: json['goal_type'] as String? ?? 'sessions',
        goalTarget: (json['goal_target'] as num?)?.toInt() ?? 0,
        isPublic: json['is_public'] as bool? ?? true,
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Challenge copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? goalType,
    int? goalTarget,
    bool? isPublic,
    String? status,
  }) =>
      Challenge(
        id: id,
        creatorId: creatorId,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        goalType: goalType ?? this.goalType,
        goalTarget: goalTarget ?? this.goalTarget,
        isPublic: isPublic ?? this.isPublic,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

class ChallengeParticipant {
  final String id;
  final String challengeId;
  final String userId;
  final double progress;
  final DateTime joinedAt;

  const ChallengeParticipant({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.progress = 0.0,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenge_id': challengeId,
        'user_id': userId,
        'progress': progress,
        'joined_at': joinedAt.toIso8601String(),
      };

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) =>
      ChallengeParticipant(
        id: json['id'] as String,
        challengeId: json['challenge_id'] as String,
        userId: json['user_id'] as String,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );

  ChallengeParticipant copyWith({double? progress}) => ChallengeParticipant(
        id: id,
        challengeId: challengeId,
        userId: userId,
        progress: progress ?? this.progress,
        joinedAt: joinedAt,
      );
}

class ChallengeMessage {
  final String id;
  final String challengeId;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  const ChallengeMessage({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.userName = '',
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenge_id': challengeId,
        'user_id': userId,
        'user_name': userName,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory ChallengeMessage.fromJson(Map<String, dynamic> json) =>
      ChallengeMessage(
        id: json['id'] as String,
        challengeId: json['challenge_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
