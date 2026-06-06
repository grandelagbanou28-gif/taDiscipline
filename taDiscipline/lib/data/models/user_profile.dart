class UserProfile {
  final String id;
  final String _displayName;
  final String? firstName;
  final String? lastName;
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
    required String displayName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.pinHash,
    this.pinSalt,
    this.biometricEnabled = false,
    this.timezone,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  }) : _displayName = displayName;

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? _displayName;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': _displayName,
        'first_name': firstName,
        'last_name': lastName,
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
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
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
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? pinHash,
    String? pinSalt,
    bool? biometricEnabled,
    String? timezone,
    bool? isVerified,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? _displayName,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
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
