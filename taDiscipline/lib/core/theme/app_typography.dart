import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontDisplay = 'Space Grotesk';
  static const String fontBody = 'Inter';
  static const String fontMono = 'JetBrains Mono';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        displaySmall: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontBody,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: fontBody,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: fontBody,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: fontBody,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontBody,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontBody,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontFamily: fontBody,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: fontBody,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: fontBody,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: fontBody,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      );

  static const TextStyle monoStyle = TextStyle(
    fontFamily: fontMono,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}
