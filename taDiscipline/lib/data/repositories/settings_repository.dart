import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class SettingsRepository {
  final SupabaseClient _client;

  SettingsRepository() : _client = AppSupabase.client;

  Future<UserSettings> getSettings(String userId) async {
    final response = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) {
      return _createDefaultSettings(userId);
    }
    return UserSettings.fromJson(response);
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    final response = await _client
        .from('user_settings')
        .upsert(settings.toJson(), onConflict: 'user_id')
        .select()
        .single();
    return UserSettings.fromJson(response);
  }

  Future<UserSettings> _createDefaultSettings(String userId) async {
    final settings = UserSettings(
      id: '',
      userId: userId,
    );
    final response = await _client
        .from('user_settings')
        .insert(settings.toJson())
        .select()
        .single();
    return UserSettings.fromJson(response);
  }
}
