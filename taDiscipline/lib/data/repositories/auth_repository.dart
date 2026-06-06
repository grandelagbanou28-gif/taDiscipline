import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/user_profile.dart';

class AuthRepository {
  Future<UserProfile> getProfile(String userId) async {
    final user = AppSession.currentUser;
    if (user != null && user.id == userId) return user;
    final db = LocalDatabase();
    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) throw Exception('Profil introuvable');
    return UserProfile.fromJson(rows.first);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await AppSession.updateProfile(profile);
  }

  Future<void> updatePinHash({
    required String userId,
    required String pinHash,
    required String salt,
  }) async {
    await AppSession.updatePinHash(userId: userId, pinHash: pinHash, salt: salt);
  }

  Future<void> updateBiometricEnabled({
    required String userId,
    required bool enabled,
  }) async {
    await AppSession.updateBiometricEnabled(userId: userId, enabled: enabled);
  }
}
