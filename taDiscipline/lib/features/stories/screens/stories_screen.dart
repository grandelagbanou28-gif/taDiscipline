import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/data/models/story.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/features/stories/providers/story_provider.dart';
import 'package:apex/features/stories/screens/story_viewer_screen.dart';

class StoriesScreen extends ConsumerWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storyListProvider);

    return SizedBox(
      height: 100,
      child: storiesAsync.when(
        loading: () => const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (stories) {
          final currentUserId = AppSession.userId;
          final myStories =
              stories.where((s) => s.userId == currentUserId).toList();
          final friendStories =
              stories.where((s) => s.userId != currentUserId).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: 1 + friendStories.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MyStoryCircle(
                  hasStories: myStories.isNotEmpty,
                  previewImage: myStories.isNotEmpty
                      ? myStories.first.imageUrl
                      : null,
                  onTap: () {
                    if (myStories.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StoryViewerScreen(
                            stories: myStories,
                            initialIndex: 0,
                          ),
                        ),
                      );
                    } else {
                      context.push('/stories/create');
                    }
                  },
                  onCreateTap: () => context.push('/stories/create'),
                );
              }
              final story = friendStories[index - 1];
              return _FriendStoryCircle(
                story: story,
                onTap: () {
                  final userStories = friendStories
                      .where((s) => s.userId == story.userId)
                      .toList();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(
                        stories: userStories,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MyStoryCircle extends StatelessWidget {
  final bool hasStories;
  final String? previewImage;
  final VoidCallback onTap;
  final VoidCallback onCreateTap;

  const _MyStoryCircle({
    required this.hasStories,
    this.previewImage,
    required this.onTap,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: hasStories ? onTap : onCreateTap,
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: hasStories
                        ? Border.all(color: AppColors.primary, width: 2.5)
                        : null,
                    image: previewImage != null
                        ? DecorationImage(
                            image: FileImage(File(previewImage!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: previewImage == null
                        ? AppColors.surfaceLight
                        : null,
                  ),
                  child: previewImage == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.textMuted,
                          size: 28,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: GestureDetector(
                      onTap: onCreateTap,
                      child: const Icon(
                        Icons.add,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ma story',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FriendStoryCircle extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const _FriendStoryCircle({
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                    AppColors.magenta,
                    AppColors.primary,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(2.5),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.textMuted,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.caption.isNotEmpty
                ? story.caption.length > 8
                    ? '${story.caption.substring(0, 8)}...'
                    : story.caption
                : 'Story',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
