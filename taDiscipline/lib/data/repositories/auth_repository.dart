import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/models/user_profile.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository() : _client = AppSupabase.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
    if (response.user != null) {
      await _createProfile(response.user!.id, displayName);
    }
    return response;
  }

  /// OAuth — Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://auth/callback',
      queryParams: {'prompt': 'select_account'},
    );
  }

  /// OAuth — Apple
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.flutter://auth/callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<UserProfile> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _client
        .from('profiles')
        .upsert(profile.toJson());
  }

  Future<void> _createProfile(String userId, String displayName) async {
    await _client.from('profiles').insert({
      'id': userId,
      'display_name': displayName,
    });
  }

  Future<void> updatePinHash({
    required String userId,
    required String pinHash,
    required String salt,
  }) async {
    await _client.from('profiles').update({
      'pin_hash': pinHash,
      'pin_salt': salt,
    }).eq('id', userId);
  }

  Future<void> updateBiometricEnabled({
    required String userId,
    required bool enabled,
  }) async {
    await _client.from('profiles').update({
      'biometric_enabled': enabled,
    }).eq('id', userId);
  }
}
