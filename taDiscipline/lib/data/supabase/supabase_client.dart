import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_discipline/core/constants/app_constants.dart';

class AppSupabase {
  AppSupabase._();

  static SupabaseClient? _instance;
  static StreamSubscription<AuthState>? _authSubscription;

  static SupabaseClient get client {
    if (_instance == null) {
      throw StateError(
        'Supabase non initialisé. Appelez AppSupabase.initialize()',
      );
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    if (_instance != null) return;

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      debug: kDebugMode,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _instance = Supabase.instance.client;

    _authSubscription?.cancel();
    _authSubscription = client.auth.onAuthStateChange.listen((event) {
      debugPrint('🔐 Auth state: ${event.event} (session: ${event.session != null})');
      if (event.event == AuthChangeEvent.signedIn) {
        debugPrint('✅ Utilisateur connecté: ${event.session?.user.email}');
      } else if (event.event == AuthChangeEvent.signedOut) {
        debugPrint('🔓 Utilisateur déconnecté');
      } else if (event.event == AuthChangeEvent.tokenRefreshed) {
        debugPrint('🔄 Token rafraîchi');
      }
    });
  }

  static void dispose() {
    _authSubscription?.cancel();
  }

  static dynamic get auth => client.auth;
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  /// Attend que l'utilisateur soit connecté (utilisé après OAuth redirect)
  static Future<User?> waitForSession({Duration timeout = const Duration(seconds: 60)}) async {
    if (currentUser != null) return currentUser;
    final completer = Completer<User?>();
    final sub = client.auth.onAuthStateChange.listen((event) {
      if (event.session?.user != null && !completer.isCompleted) {
        completer.complete(event.session!.user);
      }
    });
    final result = await completer.future.timeout(timeout, onTimeout: () => null);
    await sub.cancel();
    return result;
  }
}
