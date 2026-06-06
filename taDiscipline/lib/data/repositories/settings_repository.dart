import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/journal_entry.dart';

class SettingsRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<UserSettings> getSettings(String userId) async {
    final row = await _db.querySingle('user_settings',
        where: 'user_id = ?', whereArgs: [userId]);
    if (row == null) return _createDefaultSettings(userId);
    return UserSettings.fromJson(row);
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    await _db.insert('user_settings', settings.toJson());
    return settings;
  }

  UserSettings _createDefaultSettings(String userId) {
    final settings = UserSettings(id: '', userId: userId);
    _db.insert('user_settings', settings.toJson());
    return settings;
  }
}
