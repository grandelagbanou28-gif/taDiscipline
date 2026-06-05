import 'package:flutter/material.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final double score;

  const PasswordStrengthIndicator({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final segments = _getSegments();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: segments
              .map((s) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: s.color.withValues(alpha: s.filled ? 1.0 : 0.2),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(
          _getLabel(),
          style: TextStyle(
            fontSize: 11,
            color: _getColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<_Segment> _getSegments() {
    final filledCount = (score / 20).round();
    const colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.accent,
      AppColors.success,
      AppColors.success,
    ];
    return List.generate(
      5,
      (i) => _Segment(
        color: colors[i.clamp(0, 4)],
        filled: i < filledCount,
      ),
    );
  }

  String _getLabel() {
    if (score < 20) return 'Très faible';
    if (score < 40) return 'Faible';
    if (score < 60) return 'Moyen';
    if (score < 80) return 'Fort';
    return 'Très fort';
  }

  Color _getColor() {
    if (score < 20) return AppColors.error;
    if (score < 40) return AppColors.warning;
    if (score < 60) return AppColors.accent;
    if (score < 80) return AppColors.success;
    return AppColors.success;
  }
}

class _Segment {
  final Color color;
  final bool filled;
  _Segment({required this.color, required this.filled});
}
