import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/data/repositories/auth_repository.dart';
import 'package:ta_discipline/data/models/user_profile.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AsyncValue<UserProfile?> build() {
    _init();
    return const AsyncValue.data(null);
  }

  void _init() {
    ref.onDispose(() {});
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = AuthRepository();
      final response = await repo.signInWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final profile = await repo.getProfile(response.user!.id);
        state = AsyncValue.data(profile);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = AuthRepository();
      final response = await repo.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (response.user != null) {
        final profile = await repo.getProfile(response.user!.id);
        state = AsyncValue.data(profile);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// OAuth Google — lance le navigateur, puis attend le callback deep link
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final repo = AuthRepository();
      // Lance l'auth, ouvre le navigateur
      await repo.signInWithGoogle();
      // Attend que le deep link revienne avec la session
      final user = await AppSupabase.waitForSession();
      if (user != null) {
        final profile = await repo.getProfile(user.id);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// OAuth Apple
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      final repo = AuthRepository();
      await repo.signInWithApple();
      final user = await AppSupabase.waitForSession();
      if (user != null) {
        final profile = await repo.getProfile(user.id);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await AuthRepository().signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshProfile() async {
    final current = state.valueOrNull;
    if (current != null) {
      final profile = await AuthRepository().getProfile(current.id);
      state = AsyncValue.data(profile);
    }
  }

  /// Vérifie si une session existe déjà (au démarrage de l'app)
  Future<bool> tryRestoreSession() async {
    final session = AppSupabase.client.auth.currentSession;
    if (session != null && session.user != null) {
      try {
        final profile = await AuthRepository().getProfile(session.user!.id);
        state = AsyncValue.data(profile);
        return true;
      } catch (_) {
        // Profil pas encore créé
        state = const AsyncValue.data(null);
        return false;
      }
    }
    return false;
  }
}
