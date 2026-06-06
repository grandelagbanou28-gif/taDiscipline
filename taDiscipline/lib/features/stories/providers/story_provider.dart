import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/models/story.dart';
import 'package:apex/data/repositories/story_repository.dart';
import 'package:apex/data/local/app_session.dart';

class StoryListNotifier extends StateNotifier<AsyncValue<List<Story>>> {
  StoryListNotifier() : super(const AsyncValue.loading()) {
    _loadStories();
  }

  Future<void> _loadStories() async {
    try {
      final userId = AppSession.userId;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final stories = await StoryRepository().getActiveStories(userId);
      state = AsyncValue.data(stories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadStories();
  }

  Future<void> createStory(Story story) async {
    try {
      final created = await StoryRepository().createStory(story);
      final stories = <Story>[...state.valueOrNull ?? [], created];
      state = AsyncValue.data(stories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteStory(String storyId) async {
    try {
      await StoryRepository().deleteStory(storyId);
      final stories = (state.valueOrNull ?? [])
          .where((s) => s.id != storyId)
          .toList();
      state = AsyncValue.data(stories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final storyListProvider =
    StateNotifierProvider<StoryListNotifier, AsyncValue<List<Story>>>(
  (ref) => StoryListNotifier(),
);
