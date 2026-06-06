import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/core/constants/app_constants.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/data/repositories/pomodoro_repository.dart';
import 'package:apex/data/repositories/plan_repository.dart';
import 'package:apex/data/models/journal_entry.dart';
import 'package:apex/data/models/plan.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:uuid/uuid.dart';

final todaySessionsProvider = FutureProvider<int>((ref) {
  final userId = AppSession.userId;
  if (userId == null) return Future.value(0);
  return PomodoroRepository().getTodaySessionsCount(userId);
});

final todayMinutesProvider = FutureProvider<int>((ref) {
  final userId = AppSession.userId;
  if (userId == null) return Future.value(0);
  return PomodoroRepository().getTotalMinutesToday(userId);
});

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _secondsRemaining = AppConstants.pomodoroDefaultMinutes * 60;
  int _pomodoroCount = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  String _selectedSound = 'Nature';
  String? _currentSessionId;
  List<PlanTask> _todayTasks = [];
  String? _selectedTaskId;
  final _focusController = TextEditingController();
  bool _showQuickFocus = false;

  final _sounds = ['Silence', 'Pluie', 'Nature', 'Lo-fi', 'Café'];

  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      final plan = await PlanRepository().getPlanByDate(userId, DateTime.now());
      if (mounted) {
        setState(() => _todayTasks = plan.tasks);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusController.dispose();
    super.dispose();
  }

  Future<void> _startTimer() async {
    final userId = AppSession.userId;
    if (userId == null) return;

    if (_currentSessionId == null) {
      final session = await PomodoroRepository().createSession(
        PomodoroSession(
          id: const Uuid().v4(),
          userId: userId,
          durationMinutes: AppConstants.pomodoroDefaultMinutes,
          taskId: _selectedTaskId,
          createdAt: DateTime.now(),
        ),
      );
      _currentSessionId = session.id;
    }

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _isRunning = false;
        if (!_isBreak) {
          _pomodoroCount++;
          _completeSession();
          _startBreak();
        } else {
          if (mounted) {
            setState(() {
              _isBreak = false;
              _secondsRemaining = AppConstants.pomodoroDefaultMinutes * 60;
              _currentSessionId = null;
            });
            ref.invalidate(todaySessionsProvider);
            ref.invalidate(todayMinutesProvider);
          }
        }
      }
    });
  }

  Future<void> _completeSession() async {
    if (_currentSessionId != null) {
      await PomodoroRepository().completeSession(_currentSessionId!);
      _currentSessionId = null;
      ref.invalidate(todaySessionsProvider);
      ref.invalidate(todayMinutesProvider);
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  Future<void> _resetTimer() async {
    _timer?.cancel();
    if (_currentSessionId != null && !_isBreak) {
      await PomodoroRepository().completeSession(_currentSessionId!);
    }
    if (mounted) {
      setState(() {
        _isRunning = false;
        _isBreak = false;
        _secondsRemaining = AppConstants.pomodoroDefaultMinutes * 60;
        _currentSessionId = null;
      });
      ref.invalidate(todaySessionsProvider);
      ref.invalidate(todayMinutesProvider);
    }
  }

  void _startBreak() {
    setState(() {
      _isBreak = true;
      _secondsRemaining = _pomodoroCount % AppConstants.pomodoroCyclesBeforeLongBreak == 0
          ? AppConstants.longBreakMinutes * 60
          : AppConstants.shortBreakMinutes * 60;
      _currentSessionId = null;
    });
    _startTimer();
  }

  String _getTaskName(String? taskId) {
    if (taskId == null) return '';
    final task = _todayTasks.where((t) => t.id == taskId).firstOrNull;
    return task?.title ?? taskId;
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final total = _isBreak
        ? (_pomodoroCount % AppConstants.pomodoroCyclesBeforeLongBreak == 0
            ? AppConstants.longBreakMinutes * 60
            : AppConstants.shortBreakMinutes * 60)
        : AppConstants.pomodoroDefaultMinutes * 60;
    return 1 - (_secondsRemaining / total);
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(todaySessionsProvider);
    final minutesAsync = ref.watch(todayMinutesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: Column(
        children: [
          // Focus Stack: tache selectionnee
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: _showQuickFocus
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _focusController,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Que veux-tu accomplir ?',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check,
                              color: AppColors.success, size: 18),
                          onPressed: () {
                            if (_focusController.text.trim().isNotEmpty) {
                              setState(() {
                                _selectedTaskId = _focusController.text.trim();
                                _showQuickFocus = false;
                              });
                            }
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedTaskId,
                              isExpanded: true,
                              hint: Text(
                                _selectedTaskId != null
                                    ? 'Focus sur: ${_getTaskName(_selectedTaskId)}'
                                    : 'Sélectionne une tâche',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _selectedTaskId != null
                                      ? AppColors.primaryLight
                                      : AppColors.textMuted,
                                ),
                              ),
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Aucune tâche'),
                                ),
                                ..._todayTasks.map((t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(
                                        t.title,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                const DropdownMenuItem(
                                  value: '__quick__',
                                  child: Text('⚡ Focus rapide...'),
                                ),
                              ],
                              onChanged: (v) {
                                if (v == '__quick__') {
                                  setState(() => _showQuickFocus = true);
                                } else {
                                  setState(() => _selectedTaskId = v);
                                }
                              },
                            ),
                          ),
                        ),
                        if (_selectedTaskId != null)
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textMuted, size: 16),
                            onPressed: () {
                              setState(() => _selectedTaskId = null);
                            },
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Stats du jour
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        sessionsAsync.when(
                          data: (count) => Text(
                            '$count',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Text('0'),
                        ),
                        const Text('Sessions',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        minutesAsync.when(
                          data: (min) => Text(
                            '$min',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Text('0'),
                        ),
                        const Text('Minutes',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Text(
                  _isBreak ? 'Pause' : 'Temps de focus',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _progress.clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor: AppColors.glassBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_secondsRemaining),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Session #${_pomodoroCount + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restart_alt,
                          color: AppColors.textMuted),
                      onPressed: _resetTimer,
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          color: AppColors.textPrimary,
                          size: 32,
                        ),
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        iconSize: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.skip_next,
                          color: AppColors.textMuted),
                      onPressed: _startBreak,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Son d\'ambiance',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _sounds.map((sound) {
                    final selected = _selectedSound == sound;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedSound = sound),
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surface,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.glassBorder,
                            ),
                          ),
                          child: Text(
                            sound,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected
                                  ? AppColors.primaryLight
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
