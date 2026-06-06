import 'package:flutter/material.dart';
import 'package:apex/core/theme/app_colors.dart';

class HabitGrid extends StatelessWidget {
  final List<DateTime> dates;
  final Map<DateTime, bool> completed;
  final Color activeColor;
  final double cellSize;

  const HabitGrid({
    super.key,
    required this.dates,
    required this.completed,
    this.activeColor = AppColors.success,
    this.cellSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) return const SizedBox.shrink();

    final weeks = <List<DateTime?>>[];
    var currentWeek = <DateTime?>[];
    final firstDay = dates.first;
    final weekday = firstDay.weekday;
    for (int i = 1; i < weekday; i++) {
      currentWeek.add(null);
    }
    for (final date in dates) {
      currentWeek.add(date);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(null);
      }
      weeks.add(currentWeek);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((d) => SizedBox(
                    width: cellSize + 4,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        ...weeks.map((week) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: week.map((date) {
                  return Container(
                    width: cellSize + 4,
                    height: cellSize + 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: date != null
                          ? (completed[date] == true
                              ? activeColor
                              : AppColors.surface)
                          : Colors.transparent,
                    ),
                  );
                }).toList(),
              ),
            )),
      ],
    );
  }
}
