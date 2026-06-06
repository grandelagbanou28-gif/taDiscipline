import 'package:flutter/material.dart';
import 'package:apex/core/theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 12),
    );
  }
}
