import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/goal_categories.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/data/models/goal.dart';
import 'package:ta_discipline/data/models/habit.dart';
import 'package:ta_discipline/data/models/journal_entry.dart';
import 'package:ta_discipline/features/search/providers/search_provider.dart';
import 'package:ta_discipline/features/search/widgets/search_result_tile.dart';
import 'package:ta_discipline/features/search/widgets/filter_chips.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          onChanged: (v) =>
              ref.read(searchProvider.notifier).setQuery(v),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher…',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
            filled: false,
            suffixIcon: state.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: AppColors.textMuted),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchProvider.notifier).setQuery('');
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          FilterChipsRow(
            currentFilter: state.filter,
            onChanged: (f) =>
                ref.read(searchProvider.notifier).setFilter(f),
          ),
          const Divider(color: AppColors.glassBorder, height: 1),
          Expanded(
            child: state.query.isEmpty
                ? _emptySearch()
                : state.isEmpty
                    ? _noResults(state.query)
                    : _resultsList(state),
          ),
        ],
      ),
    );
  }

  Widget _emptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recherche dans tes données',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Objectifs, habitudes et journal',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noResults(String query) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat pour « $query »',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Essaie d\'autres termes de recherche',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultsList(SearchState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.filter == SearchFilter.all || state.filter == SearchFilter.goals)
          ..._buildGoalSection(state),
        if (state.filter == SearchFilter.all || state.filter == SearchFilter.habits)
          ..._buildHabitSection(state),
        if (state.filter == SearchFilter.all || state.filter == SearchFilter.journal)
          ..._buildJournalSection(state),
        const SizedBox(height: 32),
      ],
    );
  }

  List<Widget> _buildGoalSection(SearchState state) {
    if (state.goalResults.isEmpty) return [];
    return [
      _sectionHeader('Objectifs', state.goalResults.length),
      ...state.goalResults.map((goal) => SearchResultTile(
        icon: goal.category.emoji,
        title: goal.title,
        subtitle: goal.description.isNotEmpty
            ? goal.description
            : goal.status.label,
        date: goal.deadline ?? goal.createdAt,
        query: state.query,
        iconBackgroundColor: AppColors.cyan,
        onTap: () => context.push('/goals/${goal.id}'),
      )),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildHabitSection(SearchState state) {
    if (state.habitResults.isEmpty) return [];
    return [
      _sectionHeader('Habitudes', state.habitResults.length),
      ...state.habitResults.map((habit) => SearchResultTile(
        icon: habit.icon ?? '⭐',
        title: habit.name,
        subtitle: habit.description ?? habit.frequency.label,
        date: habit.createdAt,
        query: state.query,
        iconBackgroundColor: habit.color != null
            ? Color(int.parse(habit.color!.replaceFirst('#', '0xFF')))
            : AppColors.success,
        onTap: () => context.push('/habits'),
      )),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildJournalSection(SearchState state) {
    if (state.journalResults.isEmpty) return [];
    return [
      _sectionHeader('Journal', state.journalResults.length),
      ...state.journalResults.map((entry) => SearchResultTile(
        icon: entry.mood.emoji,
        title: entry.type.label,
        subtitle: entry.mood.label,
        date: entry.date,
        query: state.query,
        iconBackgroundColor: AppColors.accent,
        onTap: () => context.push('/journal'),
      )),
      const SizedBox(height: 8),
    ];
  }

  Widget _sectionHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
