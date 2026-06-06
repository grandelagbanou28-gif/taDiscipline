import 'package:apex/core/constants/goal_categories.dart';

class Story {
  final String id;
  final String userId;
  final String imageUrl;
  final String caption;
  final Mood mood;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Story({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption = '',
    this.mood = Mood.neutral,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'image_url': imageUrl,
        'caption': caption,
        'mood': mood.name,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        imageUrl: json['image_url'] as String? ?? '',
        caption: json['caption'] as String? ?? '',
        mood: Mood.values.firstWhere(
          (m) => m.name == json['mood'],
          orElse: () => Mood.neutral,
        ),
        createdAt: DateTime.parse(json['created_at'] as String),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );

  Story copyWith({
    String? imageUrl,
    String? caption,
    Mood? mood,
  }) =>
      Story(
        id: id,
        userId: userId,
        imageUrl: imageUrl ?? this.imageUrl,
        caption: caption ?? this.caption,
        mood: mood ?? this.mood,
        createdAt: createdAt,
        expiresAt: expiresAt,
      );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
