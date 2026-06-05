import 'package:flutter/material.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';

class SearchResultTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final DateTime? date;
  final VoidCallback? onTap;
  final String query;
  final Color? iconBackgroundColor;

  const SearchResultTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.date,
    this.onTap,
    this.query = '',
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (iconBackgroundColor ?? AppColors.primary)
                    .withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightedText(
                    title,
                    query,
                    const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildHighlightedText(
                    subtitle,
                    query,
                    const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            if (date != null) ...[
              const SizedBox(width: 8),
              Text(
                '${date!.day}/${date!.month}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle normalStyle,
    TextStyle highlightStyle, {
    int maxLines = 2,
  }) {
    if (query.isEmpty) {
      return Text(
        text,
        style: normalStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    int index = lowerText.indexOf(lowerQuery, start);
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: highlightStyle,
      ));
      start = index + lowerQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: normalStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
