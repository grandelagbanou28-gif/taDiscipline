import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/data/models/challenge.dart';
import 'package:ta_discipline/features/challenges/providers/challenge_provider.dart';
import 'package:ta_discipline/features/challenges/widgets/challenge_chat.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  final String challengeId;
  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeProvider);
    final challenge = state.publicChallenges
        .where((c) => c.id == challengeId)
        .firstOrNull;
    if (challenge == null) {
      return const Scaffold(
        body: Center(child: Text('Défi introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChallengeInfoCard(challenge: challenge),
            const SizedBox(height: 24),
            _ParticipantsSection(challengeId: challenge.id),
            const SizedBox(height: 24),
            _LeaderboardSection(challengeId: challenge.id),
            if (challenge.status == 'active') ...[
              const SizedBox(height: 24),
              _JoinLeaveButton(challenge: challenge),
            ],
            const SizedBox(height: 24),
            const Text(
              'Chat du défi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 400,
              child: ChallengeChat(challengeId: challenge.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeInfoCard extends StatelessWidget {
  final Challenge challenge;
  const _ChallengeInfoCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('🏆', style: TextStyle(fontSize: 32)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            challenge.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (challenge.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                icon: Icons.calendar_today,
                label: 'Du ${challenge.startDate.day}/${challenge.startDate.month}',
              ),
              _InfoItem(
                icon: Icons.calendar_today,
                label: 'Au ${challenge.endDate.day}/${challenge.endDate.month}',
              ),
              _InfoItem(
                icon: Icons.flag_outlined,
                label: '${challenge.goalTarget} ${_goalTypeLabel(challenge.goalType)}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _statusColor(challenge.status).withValues(alpha: 0.15),
            ),
            child: Text(
              _statusLabel(challenge.status),
              style: TextStyle(
                fontSize: 12,
                color: _statusColor(challenge.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primaryLight;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontFamily: 'JetBrains Mono',
          ),
        ),
      ],
    );
  }
}

class _ParticipantsSection extends ConsumerWidget {
  final String challengeId;
  const _ParticipantsSection({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(challengeParticipantsProvider(challengeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            participantsAsync.when(
              data: (p) => Text(
                '${p.length} inscrit(s)',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        participantsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur: $e'),
          data: (participants) {
            if (participants.isEmpty) {
              return const GlassCard(
                child: Center(
                  child: Text(
                    'Aucun participant pour le moment',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: participants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        participant.userId.substring(0, 2).toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LeaderboardSection extends ConsumerWidget {
  final String challengeId;
  const _LeaderboardSection({required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync = ref.watch(challengeParticipantsProvider(challengeId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        participantsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur: $e'),
          data: (participants) {
            if (participants.isEmpty) {
              return const GlassCard(
                child: Center(
                  child: Text(
                    'Aucun participant',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            final ranked = List<ChallengeParticipant>.from(participants)
              ..sort((a, b) => b.progress.compareTo(a.progress));
            return Column(
              children: ranked.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final medal = idx == 0
                    ? '🥇'
                    : idx == 1
                        ? '🥈'
                        : idx == 2
                            ? '🥉'
                            : '${idx + 1}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          medal,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceLight,
                          ),
                          child: Center(
                            child: Text(
                              p.userId.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Participant ${p.userId.substring(0, 6)}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '${p.progress.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _JoinLeaveButton extends ConsumerWidget {
  final Challenge challenge;
  const _JoinLeaveButton({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isParticipantAsync =
        ref.watch(challengeIsParticipantProvider(challenge.id));

    return isParticipantAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isParticipant) {
        return GlassButton(
          label: isParticipant ? 'Quitter le défi' : 'Rejoindre le défi',
          icon: isParticipant ? Icons.exit_to_app : Icons.add,
          color: isParticipant ? AppColors.error : null,
          onPressed: () {
            if (isParticipant) {
              ref
                  .read(challengeProvider.notifier)
                  .leaveChallenge(challenge.id);
            } else {
              ref
                  .read(challengeProvider.notifier)
                  .joinChallenge(challenge.id);
            }
          },
        );
      },
    );
  }
}
