import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassStyles {
  GlassStyles._();

  static BoxDecoration card({
    double blur = 20,
    double opacity = 0.08,
    double borderRadius = 16,
    Color? borderColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 0.5,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.textPrimary.withValues(alpha: 0.05),
          AppColors.textPrimary.withValues(alpha: 0.02),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.glassShadow,
          blurRadius: blur,
          spreadRadius: -2,
        ),
      ],
    );
  }

  static BoxDecoration input({
    double blur = 10,
    double borderRadius = 14,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.surface,
      border: Border.all(color: AppColors.glassBorder, width: 0.5),
    );
  }

  static BackdropFilter glassFilter({
    double blur = 20,
    Widget? child,
  }) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
