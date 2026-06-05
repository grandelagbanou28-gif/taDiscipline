import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class JournalRepository {
  final SupabaseClient _client;

  JournalRepository() : _client = AppSupabase.client;

  Future<List<JournalEntry>> getEntries(
    String userId, {
    DateTime? from,
    DateTime? to,
    int limit = 50,
  }) async {
    var query = _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId);
    if (from != null) query = query.gte('date', from.toIso8601String());
    if (to != null) query = query.lte('date', to.toIso8601String());
    final response = await query
        .order('date', ascending: false)
        .limit(limit);
    return (response as List)
        .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<JournalEntry?> getEntryByDate(String userId, DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .eq('date', dateStr)
        .maybeSingle();
    if (response == null) return null;
    return JournalEntry.fromJson(response);
  }

  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final response = await _client
        .from('journal_entries')
        .insert(entry.toJson())
        .select()
        .single();
    return JournalEntry.fromJson(response);
  }

  Future<void> deleteEntry(String entryId) async {
    await _client.from('journal_entries').delete().eq('id', entryId);
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
