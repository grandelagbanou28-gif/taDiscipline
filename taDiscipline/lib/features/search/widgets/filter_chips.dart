import 'package:flutter/material.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/features/search/providers/search_provider.dart';

class FilterChipsRow extends StatelessWidget {
  final SearchFilter currentFilter;
  final ValueChanged<SearchFilter> onChanged;

  const FilterChipsRow({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildChip(SearchFilter.all, 'Tout', Icons.search),
          const SizedBox(width: 8),
          _buildChip(SearchFilter.goals, 'Objectifs', Icons.flag_outlined),
          const SizedBox(width: 8),
          _buildChip(SearchFilter.habits, 'Habitudes', Icons.loop),
          const SizedBox(width: 8),
          _buildChip(SearchFilter.journal, 'Journal', Icons.book_outlined),
        ],
      ),
    );
  }

  Widget _buildChip(SearchFilter filter, String label, IconData icon) {
    final selected = currentFilter == filter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(filter),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selected
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.glassBorder,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
