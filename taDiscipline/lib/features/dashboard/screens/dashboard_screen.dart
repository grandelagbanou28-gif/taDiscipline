import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/animated_circular_progress.dart';
import 'package:apex/shared/widgets/streak_flame.dart';
import 'package:apex/shared/widgets/verified_badge.dart';
import 'package:apex/shared/widgets/swipe_check_tile.dart';
import 'package:apex/features/dashboard/providers/dashboard_provider.dart';
import 'package:apex/features/auth/providers/auth_provider.dart';
import 'package:apex/features/settings/providers/verified_provider.dart';
import 'package:apex/data/models/user_profile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authAsync = ref.watch(authProvider);
    final isVerified = ref.watch(verifiedProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (data) {
          final profile = authAsync.valueOrNull;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserGreeting(
                  profile: profile,
                  isVerified: isVerified,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 20),
                _DailyQuoteCard(quote: data.quote),
                const SizedBox(height: 20),
                _ScoreRow(
                  score: data.disciplineScore,
                  streak: data.streak,
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Objectifs en cours',
                  actionLabel: 'Voir tout',
                  onAction: () => context.push('/goals'),
                ),
                const SizedBox(height: 12),
                ...data.recentGoals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _GoalCard(
                      title: goal.title,
                      progress: goal.progress,
                      category: goal.category.label,
                      deadline: goal.deadline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'Habitudes du jour',
                  actionLabel: 'Voir tout',
                  onAction: () => context.push('/habits'),
                ),
                const SizedBox(height: 12),
                _HabitsRow(habits: data.todayHabits),
                const SizedBox(height: 20),
                _NextDeadlineCard(deadline: data.nextDeadline),
                const SizedBox(height: 20),
                _QuickActionsRow(),
                const SizedBox(height: 16),
                _UserProfileCard(profile: profile),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserGreeting extends StatelessWidget {
  final UserProfile? profile;
  final bool isVerified;

  const _UserGreeting({
    required this.profile,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final firstName = profile?.firstName?.isNotEmpty == true
        ? profile!.firstName!
        : 'Utilisateur';
    final avatarUrl = profile?.avatarUrl;
    final initial = (profile?.firstName?.isNotEmpty == true
            ? profile!.firstName!
            : 'U')
        .toUpperCase()[0];

    return GestureDetector(
      onTap: () => context.push('/settings'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: avatarUrl == null
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : null,
              image: avatarUrl != null
                  ? DecorationImage(
                      image: FileImage(File(avatarUrl)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatarUrl == null
                ? Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Bienvenue, $firstName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isVerified) ...[
                  const SizedBox(width: 6),
                  const VerifiedBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuoteCard extends StatelessWidget {
  final String quote;
  const _DailyQuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradientColors: [
        AppColors.primary.withValues(alpha: 0.1),
        AppColors.primaryDark.withValues(alpha: 0.05),
      ],
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: AppColors.accent, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int score;
  final int streak;
  const _ScoreRow({required this.score, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedCircularProgress(
          progress: score / 100,
          size: 100,
          centerText: '$score',
          subtitle: 'Score',
        ),
        const SizedBox(width: 20),
        StreakFlame(streak: streak),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jours consécutifs',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$streak jours 🔥',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double progress;
  final String category;
  final DateTime? deadline;
  const _GoalCard({
    required this.title,
    required this.progress,
    required this.category,
    this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppColors.glassBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (deadline != null)
                Text(
                  '${deadline!.difference(DateTime.now()).inDays} jours restants',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitsRow extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  const _HabitsRow({required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return GlassCard(
        child: Center(
          child: Text(
            'Aucune habitude aujourd\'hui. Crée-en une !',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
    return Column(
      children: habits.map((h) => SwipeCheckTile(
        title: h['name'] as String? ?? '',
        icon: Icons.repeat,
        color: AppColors.success,
        onComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habitude complétée !'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onSnooze: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habitude reportée'),
              backgroundColor: AppColors.warning,
            ),
          );
        },
      )).toList(),
    );
  }
}

class _NextDeadlineCard extends StatelessWidget {
  final DateTime? deadline;
  const _NextDeadlineCard({this.deadline});

  @override
  Widget build(BuildContext context) {
    if (deadline == null) return const SizedBox.shrink();
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    return GlassCard(
      gradientColors: [AppColors.accent.withValues(alpha: 0.05), Colors.transparent],
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prochaine échéance',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$daysLeft jours',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Objectif',
              color: AppColors.primary,
              onTap: () => context.push('/goals/create'),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Habitude',
              color: AppColors.success,
              onTap: () => context.push('/habits/create'),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.timer_outlined,
              label: 'Pomodoro',
              color: AppColors.accent,
              onTap: () => context.push('/pomodoro'),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.edit_note,
              label: 'Journal',
              color: AppColors.cyan,
              onTap: () => context.push('/journal'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickAction(
              icon: Icons.emoji_events_outlined,
              label: 'Défis',
              color: AppColors.gold,
              onTap: () => context.push('/challenges'),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.videocam_outlined,
              label: 'Appel',
              color: AppColors.primaryLight,
              onTap: () => context.push('/challenges'),
            ),
            const SizedBox(width: 12),
            _QuickAction(
              icon: Icons.search,
              label: 'Recherche',
              color: AppColors.textSecondary,
              onTap: () => context.push('/search'),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileCard extends StatelessWidget {
  final UserProfile? profile;

  const _UserProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/settings'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: profile?.avatarUrl == null
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : null,
              image: profile?.avatarUrl != null
                  ? DecorationImage(
                      image: FileImage(File(profile!.avatarUrl!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: profile?.avatarUrl == null
                ? Center(
                    child: Text(
                      ((profile?.firstName?.isNotEmpty == true
                              ? profile!.firstName!
                              : 'U')
                          .toUpperCase()[0]),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.displayName ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Modifier le profil',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
