import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class AppSession {
  AppSession._();

  static final LocalDatabase _db = LocalDatabase();
  static UserProfile? _currentUser;

  static UserProfile? get currentUser => _currentUser;
  static String? get userId => _currentUser?.id;

  static Future<UserProfile> ensureUser() async {
    if (_currentUser != null) return _currentUser!;

    final rows = await _db.query('profiles', limit: 1);
    if (rows.isNotEmpty) {
      _currentUser = UserProfile.fromJson(rows.first);
      return _currentUser!;
    }

    final now = DateTime.now();
    final profile = UserProfile(
      id: const Uuid().v4(),
      displayName: 'Moi',
      createdAt: now,
      updatedAt: now,
    );
    await _db.insert('profiles', profile.toJson());
    _currentUser = profile;
    return profile;
  }

  static Future<void> updateProfile(UserProfile profile) async {
    await _db.update('profiles', profile.toJson(),
        where: 'id = ?', whereArgs: [profile.id]);
    _currentUser = profile;
  }

  static Future<void> setDisplayName(String name) async {
    final user = await ensureUser();
    final updated = user.copyWith(displayName: name);
    await updateProfile(updated);
  }

  static Future<void> updatePinHash({
    required String userId,
    required String pinHash,
    required String salt,
  }) async {
    final user = await ensureUser();
    final updated = user.copyWith(pinHash: pinHash);
    await _db.update('profiles', {
      'pin_hash': pinHash,
      'pin_salt': salt,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [userId]);
    _currentUser = updated;
  }

  static Future<void> updateBiometricEnabled({
    required String userId,
    required bool enabled,
  }) async {
    await _db.update('profiles', {
      'biometric_enabled': enabled ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [userId]);
    if (_currentUser?.id == userId) {
      _currentUser = _currentUser!.copyWith(biometricEnabled: enabled);
    }
  }

  static Future<void> signOut() async {
    _currentUser = null;
  }

  static void dispose() {
    _currentUser = null;
  }
}
