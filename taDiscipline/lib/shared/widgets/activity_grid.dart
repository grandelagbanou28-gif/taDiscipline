import 'package:flutter/material.dart';
import 'package:apex/core/theme/app_colors.dart';

class ActivityGrid extends StatelessWidget {
  final Map<DateTime, int> data;
  final int months;

  const ActivityGrid({
    super.key,
    required this.data,
    this.months = 3,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - months + 1, 1);
    final totalDays = now.difference(start).inDays + 1;
    final cols = ((totalDays + 6) ~/ 7).clamp(1, 54);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) => SizedBox(
            width: 14,
            child: Text(d,
                style: const TextStyle(
                    fontSize: 8, color: AppColors.textMuted)),
          )).toList(),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 7 * 14.0,
          child: Column(
            children: List.generate(7, (row) {
              return Row(
                children: List.generate(cols, (col) {
                  final dayNum = col * 7 + row - start.weekday + 1;
                  final date = DateTime(start.year, start.month, dayNum);
                  if (date.isAfter(now) || date.isBefore(start)) {
                    return _emptyCell();
                  }
                  final key = DateTime(date.year, date.month, date.day);
                  final level = data[key] ?? 0;
                  return _cell(level);
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendLabel('Moins'),
            ...List.generate(5, (i) => _cell(i)),
            _legendLabel('Plus'),
          ],
        ),
      ],
    );
  }

  Widget _cell(int level) {
    final colors = [
      AppColors.surface,
      AppColors.primary.withValues(alpha: 0.2),
      AppColors.primary.withValues(alpha: 0.4),
      AppColors.primaryLight.withValues(alpha: 0.6),
      AppColors.primaryLight,
    ];
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: colors[level.clamp(0, 4)],
      ),
    );
  }

  Widget _emptyCell() {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
    );
  }

  Widget _legendLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
      ),
    );
  }
}
