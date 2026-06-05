import 'dart:ui';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);

  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xCC1E293B);
  static const Color surfaceLight = Color(0xCC334155);

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color cyan = Color(0xFF06B6D4);
  static const Color magenta = Color(0xFFD946EF);
  static const Color indigo = Color(0xFF6366F1);

  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);
  static Color glassShadow = const Color(0xFF000000).withValues(alpha: 0.25);

  static const Color gold = Color(0xFFF59E0B);
  static const Color goldenParticle = Color(0xFFF59E0B);

  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF5B21B6),
    Color(0xFF1E3A8A),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF0F172A),
    Color(0xFF1E1B4B),
  ];

  static const List<Color> auroraGradient = [
    Color(0xFF06B6D4),
    Color(0xFFD946EF),
  ];

  static const List<Color> achievementGlow = [
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
  ];
}
