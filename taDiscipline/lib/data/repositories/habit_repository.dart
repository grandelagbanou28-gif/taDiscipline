import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/habit.dart';

class HabitRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Habit>> getHabits(String userId) async {
    final rows = await _db.query('habits',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows.map((j) => Habit.fromJson(j)).toList();
  }

  Future<Habit> createHabit(Habit habit) async {
    await _db.insert('habits', habit.toJson());
    return habit;
  }

  Future<Habit> updateHabit(Habit habit) async {
    await _db.update('habits', habit.toJson(), where: 'id = ?', whereArgs: [habit.id]);
    return habit;
  }

  Future<void> deleteHabit(String habitId) async {
    await _db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
  }

  Future<List<HabitLog>> getHabitLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var where = 'habit_id = ?';
    final args = [habitId];
    if (from != null) {
      where += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND date <= ?';
      args.add(to.toIso8601String());
    }
    final rows =
        await _db.query('habit_logs', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map((j) => HabitLog.fromJson(j)).toList();
  }

  Future<HabitLog> logHabit(HabitLog log) async {
    await _db.insert('habit_logs', log.toJson());
    return log;
  }

  Future<int> getCurrentStreak(String habitId) async {
    final logs = await getHabitLogs(habitId);
    if (logs.isEmpty) return 0;
    final sorted = logs
        .where((l) => l.completed)
        .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    if (sorted.isEmpty) return 0;
    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i - 1].difference(sorted[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
