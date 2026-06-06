import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/models/user_profile.dart';

class AuthNotifier extends Notifier<AsyncValue<UserProfile?>> {
  @override
  AsyncValue<UserProfile?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await AppSession.ensureUser();
      state = AsyncValue.data(user);
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
      await AppSession.setDisplayName(displayName);
      final user = await AppSession.ensureUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await AppSession.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshProfile() async {
    final current = state.valueOrNull;
    if (current != null) {
      final updated = await AppSession.ensureUser();
      state = AsyncValue.data(updated);
    }
  }

  Future<bool> tryRestoreSession() async {
    try {
      final user = await AppSession.ensureUser();
      state = AsyncValue.data(user);
      return true;
    } catch (_) {
      state = const AsyncValue.data(null);
      return false;
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>(
  AuthNotifier.new,
);

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).valueOrNull?.id;
});
