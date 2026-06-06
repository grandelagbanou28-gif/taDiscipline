import 'package:apex/data/repositories/settings_repository.dart';
import 'package:apex/data/local/app_session.dart';

class SleepService {
  final SettingsRepository _repo;

  SleepService() : _repo = SettingsRepository();

  Future<bool> isSleepTime() async {
    final userId = AppSession.userId;
    if (userId == null) return false;
    try {
      final settings = await _repo.getSettings(userId);
      if (!settings.sleepResetEnabled || settings.sleepTime == null) {
        return false;
      }
      final parts = settings.sleepTime!.split(':');
      if (parts.length != 2) return false;
      final sleepHour = int.tryParse(parts[0]) ?? 0;
      final sleepMinute = int.tryParse(parts[1]) ?? 0;
      final now = DateTime.now();
      final sleep = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
      return now.isAfter(sleep);
    } catch (_) {
      return false;
    }
  }

  Future<bool> shouldReset() async {
    final userId = AppSession.userId;
    if (userId == null) return false;
    try {
      final settings = await _repo.getSettings(userId);
      if (!settings.sleepResetEnabled || settings.sleepTime == null) {
        return false;
      }
      final parts = settings.sleepTime!.split(':');
      if (parts.length != 2) return false;
      final sleepHour = int.tryParse(parts[0]) ?? 0;
      final sleepMinute = int.tryParse(parts[1]) ?? 0;
      final now = DateTime.now();
      final sleep = DateTime(now.year, now.month, now.day, sleepHour, sleepMinute);
      return now.isAfter(sleep);
    } catch (_) {
      return false;
    }
  }
}
