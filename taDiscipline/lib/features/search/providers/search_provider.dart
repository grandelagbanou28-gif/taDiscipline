import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/models/goal.dart';
import 'package:apex/data/models/habit.dart';
import 'package:apex/data/models/journal_entry.dart';
import 'package:apex/data/repositories/journal_repository.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/features/goals/providers/goal_provider.dart';
import 'package:apex/features/habits/providers/habit_provider.dart';

enum SearchFilter { all, goals, habits, journal }

enum SearchSort { date, title, progress }

class SearchState {
  final String query;
  final SearchFilter filter;
  final SearchSort sort;
  final List<Goal> goalResults;
  final List<Habit> habitResults;
  final List<JournalEntry> journalResults;

  const SearchState({
    this.query = '',
    this.filter = SearchFilter.all,
    this.sort = SearchSort.date,
    this.goalResults = const [],
    this.habitResults = const [],
    this.journalResults = const [],
  });

  bool get isEmpty =>
      goalResults.isEmpty && habitResults.isEmpty && journalResults.isEmpty;

  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    SearchSort? sort,
    List<Goal>? goalResults,
    List<Habit>? habitResults,
    List<JournalEntry>? journalResults,
  }) =>
      SearchState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
        sort: sort ?? this.sort,
        goalResults: goalResults ?? this.goalResults,
        habitResults: habitResults ?? this.habitResults,
        journalResults: journalResults ?? this.journalResults,
      );
}

final journalEntryListProvider =
    FutureProvider<List<JournalEntry>>((ref) async {
  final userId = AppSession.userId;
  if (userId == null) return [];
  return JournalRepository().getEntries(userId);
});

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;

  SearchNotifier(this._ref) : super(const SearchState()) {
    _ref.listen(goalListProvider, (_, __) => _performSearch());
    _ref.listen(habitListProvider, (_, __) => _performSearch());
    _ref.listen(journalEntryListProvider, (_, __) => _performSearch());
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
    _performSearch();
  }

  void setFilter(SearchFilter f) {
    state = state.copyWith(filter: f);
    _performSearch();
  }

  void setSort(SearchSort s) {
    state = state.copyWith(sort: s);
    _applySort();
  }

  void _performSearch() {
    final query = state.query.toLowerCase().trim();
    final filter = state.filter;

    if (query.isEmpty) {
      state = state.copyWith(
        goalResults: const [],
        habitResults: const [],
        journalResults: const [],
      );
      return;
    }

    final allGoals = _ref.read(goalListProvider).valueOrNull ?? [];
    final allHabits = _ref.read(habitListProvider).valueOrNull ?? [];
    final allJournals = _ref.read(journalEntryListProvider).valueOrNull ?? [];

    List<Goal> goalResults = [];
    List<Habit> habitResults = [];
    List<JournalEntry> journalResults = [];

    if (filter == SearchFilter.all || filter == SearchFilter.goals) {
      goalResults = allGoals.where((g) {
        return g.title.toLowerCase().contains(query) ||
            g.description.toLowerCase().contains(query);
      }).toList();
    }

    if (filter == SearchFilter.all || filter == SearchFilter.habits) {
      habitResults = allHabits.where((h) {
        return h.name.toLowerCase().contains(query) ||
            (h.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (filter == SearchFilter.all || filter == SearchFilter.journal) {
      journalResults = allJournals.where((j) {
        final dateStr =
            '${j.date.day}/${j.date.month}/${j.date.year}';
        return dateStr.contains(query) ||
            j.mood.label.toLowerCase().contains(query) ||
            j.type.label.toLowerCase().contains(query);
      }).toList();
    }

    state = state.copyWith(
      goalResults: goalResults,
      habitResults: habitResults,
      journalResults: journalResults,
    );

    _applySort();
  }

  void _applySort() {
    switch (state.sort) {
      case SearchSort.date:
        state = state.copyWith(
          goalResults: [...state.goalResults]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          habitResults: [...state.habitResults]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          journalResults: [...state.journalResults]
            ..sort((a, b) => b.date.compareTo(a.date)),
        );
      case SearchSort.title:
        state = state.copyWith(
          goalResults: [...state.goalResults]
            ..sort((a, b) => a.title.compareTo(b.title)),
          habitResults: [...state.habitResults]
            ..sort((a, b) => a.name.compareTo(b.name)),
          journalResults: [...state.journalResults]
            ..sort((a, b) => a.date.compareTo(b.date)),
        );
      case SearchSort.progress:
        state = state.copyWith(
          goalResults: [...state.goalResults]
            ..sort((a, b) => b.progress.compareTo(a.progress)),
          habitResults: [...state.habitResults]
            ..sort((a, b) => b.target.compareTo(a.target)),
          journalResults: [...state.journalResults]
            ..sort((a, b) => b.date.compareTo(a.date)),
        );
    }
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
