import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/data/models/challenge.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/features/challenges/providers/challenge_provider.dart';
import 'package:apex/shared/widgets/glass_card.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Défis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explorer'),
            Tab(text: 'Mes défis'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ExplorerTab(challenges: state.publicChallenges),
                _MyChallengesTab(challenges: state.myChallenges),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/challenges/create'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ExplorerTab extends ConsumerWidget {
  final List<Challenge> challenges;
  const _ExplorerTab({required this.challenges});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Aucun défi public pour le moment',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sois le premier à en créer un !',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(challengeProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return _ChallengeCard(challenge: challenge);
        },
      ),
    );
  }
}

class _ChallengeCard extends ConsumerWidget {
  final Challenge challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(challenge.id));

    return GlassCard(
      onTap: () => context.push('/challenges/${challenge.id}'),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                _categoryEmoji(challenge.category),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${challenge.startDate.day}/${challenge.startDate.month} - ${challenge.endDate.day}/${challenge.endDate.month}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              participantsAsync.when(
                data: (p) => Text(
                  '${p.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Text('0',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const Spacer(),
              Text(
                '${challenge.goalTarget} ${_goalTypeLabel(challenge.goalType)}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: GlassButtonSmall(
              label: 'Rejoindre',
              onPressed: () {
                ref
                    .read(challengeProvider.notifier)
                    .joinChallenge(challenge.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'fitness':
        return '🏋️';
      case 'learning':
        return '📚';
      case 'health':
        return '🏥';
      case 'creativity':
        return '🎨';
      case 'finance':
        return '💰';
      case 'career':
        return '💼';
      case 'spirituality':
        return '🧘';
      default:
        return '📌';
    }
  }

  String _goalTypeLabel(String type) {
    switch (type) {
      case 'streak':
        return 'jours';
      case 'sessions':
        return 'séances';
      case 'minutes':
        return 'min';
      case 'distance':
        return 'km';
      default:
        return type;
    }
  }
}

class GlassButtonSmall extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GlassButtonSmall({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyChallengesTab extends ConsumerWidget {
  final List<Challenge> challenges;
  const _MyChallengesTab({required this.challenges});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Aucun défi rejoint',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore les défis publics et rejoins-en un !',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(challengeProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return _MyChallengeItem(challenge: challenge);
        },
      ),
    );
  }
}

class _MyChallengeItem extends ConsumerWidget {
  final Challenge challenge;
  const _MyChallengeItem({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(_currentUserIdProvider);
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(challenge.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push('/challenges/${challenge.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${challenge.startDate.day}/${challenge.startDate.month} - ${challenge.endDate.day}/${challenge.endDate.month}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            participantsAsync.when(
              data: (participants) {
                final myProgress = participants
                    .where((p) => p.userId == userId)
                    .firstOrNull
                    ?.progress ?? 0.0;
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: myProgress / challenge.goalTarget,
                        backgroundColor: AppColors.glassBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${myProgress.toInt()}/${challenge.goalTarget}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(myProgress / challenge.goalTarget * 100).toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

final _currentUserIdProvider = Provider<String?>((ref) {
  return AppSession.userId;
});
