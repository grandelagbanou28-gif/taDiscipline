import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/features/calls/providers/call_provider.dart';

class CallScreen extends ConsumerWidget {
  final String roomName;
  final String? participantName;

  const CallScreen({
    super.key,
    required this.roomName,
    this.participantName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Appel')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    participantName != null ? Icons.person : Icons.videocam,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  participantName ?? 'Appel vocal/visio',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Salle: $roomName',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  label: callState.isInCall
                      ? 'Appel en cours...'
                      : 'Rejoindre l\'appel',
                  onPressed: callState.isInCall
                      ? null
                      : () async {
                          await ref.read(callProvider.notifier).startCall(
                            roomName,
                            displayName: participantName,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  icon: callState.isInCall
                      ? Icons.hourglass_top
                      : Icons.phone_in_talk,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
