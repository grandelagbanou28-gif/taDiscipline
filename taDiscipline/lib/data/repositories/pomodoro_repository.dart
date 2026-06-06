import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/journal_entry.dart';

class PomodoroRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<PomodoroSession>> getSessions(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var where = 'user_id = ?';
    final args = <dynamic>[userId];
    if (from != null) {
      where += ' AND created_at >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND created_at <= ?';
      args.add(DateTime(to.year, to.month, to.day, 23, 59, 59).toIso8601String());
    }
    final rows = await _db.query('pomodoro_sessions',
        where: where, whereArgs: args, orderBy: 'created_at DESC');
    return rows.map((j) => PomodoroSession.fromJson(j)).toList();
  }

  Future<PomodoroSession> createSession(PomodoroSession session) async {
    await _db.insert('pomodoro_sessions', session.toJson());
    return session;
  }

  Future<PomodoroSession> completeSession(String sessionId) async {
    final now = DateTime.now().toIso8601String();
    await _db.update('pomodoro_sessions', {'completed_at': now},
        where: 'id = ?', whereArgs: [sessionId]);
    final row =
        await _db.querySingle('pomodoro_sessions', where: 'id = ?', whereArgs: [sessionId]);
    return PomodoroSession.fromJson(row!);
  }

  Future<int> getTodaySessionsCount(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final rows = await _db.query('pomodoro_sessions',
        where:
            'user_id = ? AND created_at >= ? AND created_at <= ? AND completed_at IS NOT NULL',
        whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        columns: ['id']);
    return rows.length;
  }

  Future<int> getTotalMinutesToday(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    final rows = await _db.query('pomodoro_sessions',
        where:
            'user_id = ? AND created_at >= ? AND created_at <= ? AND completed_at IS NOT NULL',
        whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        columns: ['duration']);
    return rows.fold<int>(0, (sum, r) => sum + ((r['duration'] as num?)?.toInt() ?? 0));
  }
}
