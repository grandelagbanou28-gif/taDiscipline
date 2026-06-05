import 'package:flutter/material.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';

class CallButton extends StatelessWidget {
  final String roomName;
  final VoidCallback onPressed;

  const CallButton({
    super.key,
    required this.roomName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: const Icon(
              Icons.phone,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
