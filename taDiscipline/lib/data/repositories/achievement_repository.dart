import 'package:apex/core/constants/goal_categories.dart';
import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/journal_entry.dart';

class AchievementRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Achievement>> getAchievements(String userId) async {
    final rows = await _db.query('achievements',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'unlocked_at DESC');
    return rows.map((j) => Achievement.fromJson(j)).toList();
  }

  Future<void> unlockAchievement(String userId, BadgeType badge) async {
    await _db.insert('achievements', {
      'user_id': userId,
      'badge_id': badge.name,
      'unlocked_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> hasAchievement(String userId, BadgeType badge) async {
    final row = await _db.querySingle('achievements',
        where: 'user_id = ? AND badge_id = ?', whereArgs: [userId, badge.name]);
    return row != null;
  }

  Future<Set<BadgeType>> getUnlockedBadges(String userId) async {
    final achievements = await getAchievements(userId);
    return achievements.map((a) => a.badge).toSet();
  }
}
