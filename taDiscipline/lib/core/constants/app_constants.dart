import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'taDiscipline';
  static const String slogan = 'Maîtrise ton quotidien, conquiers tes rêves.';

  static const String defaultQuote =
      'La discipline est le pont entre les objectifs et leurs accomplissements.';
  static const String quoteAuthor = 'Jim Rohn';

  static const int pinLength = 6;
  static const int minPasswordLength = 8;
  static const int autoLockMinutes = 2;
  static const int pomodoroDefaultMinutes = 25;
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;
  static const int pomodoroCyclesBeforeLongBreak = 4;
  static const int maxPinAttempts = 5;
  static const int pinLockoutMinutes = 15;

  static const double designWidth = 390;
  static const double designHeight = 844;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);

  /// Supabase URL — fournie via --dart-define SUPABASE_URL ou variable d'environnement.
  /// Se lit dans l'ordre : dart-define > variable env > fallback vide.
  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    const fromEnv = String.fromEnvironment('SUPABASE_URL',
        defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'https://votre-projet.supabase.co';
  }

  /// Supabase anon key (publique, sans danger).
  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'votre-anon-key';
  }

  /// Clé xAI / Grok — utilisée côté Edge Function uniquement.
  static String get xaiApiKey {
    const fromDefine = String.fromEnvironment('XAI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    const fromEnv = String.fromEnvironment('XAI_API_KEY',
        defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    return '';
  }

  /// Endpoint pour DelAide IA (Vercel ou Supabase Edge Function).
  /// Surchargeable via --dart-define DELAIDE_API_URL=https://xxx.vercel.app/api/delaide-chat
  static String get delaideApiEndpoint {
    const customUrl = String.fromEnvironment('DELAIDE_API_URL');
    if (customUrl.isNotEmpty) return customUrl;
    return '$supabaseUrl/functions/v1/delaide-chat';
  }

  /// Vrai en production
  static bool get isProduction => kReleaseMode;
}
