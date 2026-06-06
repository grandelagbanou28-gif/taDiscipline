import 'package:apex/core/constants/goal_categories.dart';

class JournalEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String contentEncrypted;
  final Mood mood;
  final JournalType type;
  final DateTime createdAt;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.contentEncrypted,
    this.mood = Mood.neutral,
    this.type = JournalType.morning,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'date': date.toIso8601String(),
        'content_encrypted': contentEncrypted,
        'mood': mood.name,
        'type': type.name,
        'created_at': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        date: DateTime.parse(json['date'] as String),
        contentEncrypted: json['content_encrypted'] as String? ?? '',
        mood: Mood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => Mood.neutral,
        ),
        type: JournalType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => JournalType.morning,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class PomodoroSession {
  final String id;
  final String userId;
  final int durationMinutes;
  final DateTime? completedAt;
  final String? taskId;
  final DateTime createdAt;

  const PomodoroSession({
    required this.id,
    required this.userId,
    this.durationMinutes = 25,
    this.completedAt,
    this.taskId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'duration': durationMinutes,
        'completed_at': completedAt?.toIso8601String(),
        'task_id': taskId,
        'created_at': createdAt.toIso8601String(),
      };

  factory PomodoroSession.fromJson(Map<String, dynamic> json) =>
      PomodoroSession(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        durationMinutes: (json['duration'] as num?)?.toInt() ?? 25,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        taskId: json['task_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ChatMessage {
  final String id;
  final String userId;
  final String role;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'role': role,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        role: json['role'] as String? ?? 'user',
        content: json['content'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class Achievement {
  final String id;
  final String userId;
  final BadgeType badge;
  final DateTime unlockedAt;

  const Achievement({
    required this.id,
    required this.userId,
    required this.badge,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'badge_id': badge.name,
        'unlocked_at': unlockedAt.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        badge: BadgeType.values.firstWhere(
          (b) => b.name == json['badge_id'],
          orElse: () => BadgeType.firstGoal,
        ),
        unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      );
}

class UserSettings {
  final String id;
  final String userId;
  final String theme;
  final bool notificationsEnabled;
  final int lockTimeoutMinutes;
  final String language;
  final String? sleepTime;
  final bool sleepResetEnabled;
  final dynamic pingSchedules;

  const UserSettings({
    required this.id,
    required this.userId,
    this.theme = 'dark',
    this.notificationsEnabled = true,
    this.lockTimeoutMinutes = 2,
    this.language = 'fr',
    this.sleepTime,
    this.sleepResetEnabled = false,
    this.pingSchedules,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'theme': theme,
        'notifications': notificationsEnabled,
        'lock_timeout': lockTimeoutMinutes,
        'language': language,
        'sleep_time': sleepTime,
        'sleep_reset_enabled': sleepResetEnabled,
        'ping_schedules': pingSchedules,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        theme: json['theme'] as String? ?? 'dark',
        notificationsEnabled: json['notifications'] as bool? ?? true,
        lockTimeoutMinutes: (json['lock_timeout'] as num?)?.toInt() ?? 2,
        language: json['language'] as String? ?? 'fr',
        sleepTime: json['sleep_time'] as String?,
        sleepResetEnabled: json['sleep_reset_enabled'] as bool? ?? false,
        pingSchedules: json['ping_schedules'],
      );

  UserSettings copyWith({
    String? theme,
    bool? notificationsEnabled,
    int? lockTimeoutMinutes,
    String? language,
    String? sleepTime,
    bool? sleepResetEnabled,
    dynamic pingSchedules,
  }) =>
      UserSettings(
        id: id,
        userId: userId,
        theme: theme ?? this.theme,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        lockTimeoutMinutes: lockTimeoutMinutes ?? this.lockTimeoutMinutes,
        language: language ?? this.language,
        sleepTime: sleepTime ?? this.sleepTime,
        sleepResetEnabled: sleepResetEnabled ?? this.sleepResetEnabled,
        pingSchedules: pingSchedules ?? this.pingSchedules,
      );
}
