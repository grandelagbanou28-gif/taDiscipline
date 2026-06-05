class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? pinHash;
  final String? pinSalt;
  final bool biometricEnabled;
  final String? timezone;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.pinHash,
    this.pinSalt,
    this.biometricEnabled = false,
    this.timezone,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'pin_hash': pinHash,
        'pin_salt': pinSalt,
        'biometric_enabled': biometricEnabled,
        'timezone': timezone,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        pinHash: json['pin_hash'] as String?,
        pinSalt: json['pin_salt'] as String?,
        biometricEnabled: json['biometric_enabled'] as bool? ?? false,
        timezone: json['timezone'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? pinHash,
    String? pinSalt,
    bool? biometricEnabled,
    String? timezone,
    bool? isVerified,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        pinHash: pinHash ?? this.pinHash,
        pinSalt: pinSalt ?? this.pinSalt,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        timezone: timezone ?? this.timezone,
        isVerified: isVerified ?? this.isVerified,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
