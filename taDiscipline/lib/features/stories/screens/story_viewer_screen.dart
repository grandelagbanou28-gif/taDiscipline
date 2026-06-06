import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/data/models/story.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int _currentIndex;
  late PageController _pageController;
  Timer? _timer;
  double _progress = 0.0;
  static const _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _progress = 0.0;
    const tickDuration = Duration(milliseconds: 50);
    final totalTicks = _storyDuration.inMilliseconds ~/ tickDuration.inMilliseconds;
    int ticks = 0;
    _timer = Timer.periodic(tickDuration, (timer) {
      ticks++;
      setState(() {
        _progress = ticks / totalTicks;
      });
      if (ticks >= totalTicks) {
        _goNext();
      }
    });
  }

  void _goNext() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onTap(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < screenWidth / 3) {
      _goPrevious();
    } else if (details.localPosition.dx > screenWidth * 2 / 3) {
      _goNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: _onTap,
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _startTimer();
          },
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                if (story.imageUrl.startsWith('http'))
                  Image.network(
                    story.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.textMuted,
                        size: 48,
                      ),
                    ),
                  )
                else
                  Image.file(
                    File(story.imageUrl),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.textMuted,
                        size: 48,
                      ),
                    ),
                  ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Row(
                        children: widget.stories.asMap().entries.map((entry) {
                          final i = entry.key;
                          return Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: i < _currentIndex
                                    ? AppColors.textPrimary
                                    : i == _currentIndex
                                        ? AppColors.textPrimary
                                            .withValues(alpha: 0.5)
                                        : AppColors.textPrimary
                                            .withValues(alpha: 0.2),
                              ),
                              child: i == _currentIndex
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: _progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceLight,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Story ${_currentIndex + 1}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (story.caption.isNotEmpty)
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 32,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        story.caption,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      story.mood.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
