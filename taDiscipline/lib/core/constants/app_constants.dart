import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Apex';
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

  /// Clé xAI / Grok.
  static String get xaiApiKey {
    const fromDefine = String.fromEnvironment('XAI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    const fromEnv = String.fromEnvironment('XAI_API_KEY', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    return '';
  }

  /// Vrai en production
  static bool get isProduction => kReleaseMode;
}
