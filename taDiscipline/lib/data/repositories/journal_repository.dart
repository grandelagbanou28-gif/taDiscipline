import 'package:apex/core/constants/goal_categories.dart';
import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/journal_entry.dart';

class JournalRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<JournalEntry>> getEntries(
    String userId, {
    DateTime? from,
    DateTime? to,
    int limit = 50,
  }) async {
    var where = 'user_id = ?';
    final args = <dynamic>[userId];
    if (from != null) {
      where += ' AND date >= ?';
      args.add(from.toIso8601String());
    }
    if (to != null) {
      where += ' AND date <= ?';
      args.add(to.toIso8601String());
    }
    final rows = await _db.query('journal_entries',
        where: where, whereArgs: args, orderBy: 'date DESC', limit: limit);
    return rows.map((j) => JournalEntry.fromJson(j)).toList();
  }

  Future<JournalEntry?> getEntryByDate(String userId, DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final row = await _db.querySingle('journal_entries',
        where: 'user_id = ? AND date = ?', whereArgs: [userId, dateStr]);
    if (row == null) return null;
    return JournalEntry.fromJson(row);
  }

  Future<JournalEntry> createEntry(JournalEntry entry) async {
    await _db.insert('journal_entries', entry.toJson());
    return entry;
  }

  Future<void> deleteEntry(String entryId) async {
    await _db.delete('journal_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  Future<Map<DateTime, Mood>> getMoodHistory(String userId, int days) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final entries = await getEntries(userId, from: from);
    return {
      for (final entry in entries)
        DateTime(entry.date.year, entry.date.month, entry.date.day): entry.mood,
    };
  }
}
