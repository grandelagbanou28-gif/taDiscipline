import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/models/challenge.dart';
import 'package:apex/data/repositories/challenge_repository.dart';
import 'package:apex/data/local/app_session.dart';

class ChallengeState {
  final List<Challenge> publicChallenges;
  final List<Challenge> myChallenges;
  final bool isLoading;
  final String? error;

  const ChallengeState({
    this.publicChallenges = const [],
    this.myChallenges = const [],
    this.isLoading = false,
    this.error,
  });

  ChallengeState copyWith({
    List<Challenge>? publicChallenges,
    List<Challenge>? myChallenges,
    bool? isLoading,
    String? error,
  }) =>
      ChallengeState(
        publicChallenges: publicChallenges ?? this.publicChallenges,
        myChallenges: myChallenges ?? this.myChallenges,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repo;

  ChallengeNotifier(this._repo) : super(const ChallengeState());

  Future<void> loadChallenges() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userId = AppSession.userId;
      final results = await Future.wait([
        _repo.getPublicChallenges(),
        if (userId != null) _repo.getMyChallenges(userId) else Future.value([]),
      ]);
      state = state.copyWith(
        publicChallenges: results[0] as List<Challenge>,
        myChallenges: results[1] as List<Challenge>,
        isLoading: false,
      );
    } catch (e, st) {
      debugPrint('Erreur chargement défis: $e\n$st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createChallenge(Challenge challenge) async {
    try {
      final created = await _repo.createChallenge(challenge);
      state = state.copyWith(
        publicChallenges: [created, ...state.publicChallenges],
        myChallenges: [created, ...state.myChallenges],
      );
    } catch (e) {
      debugPrint('Erreur création défi: $e');
      rethrow;
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      await _repo.joinChallenge(challengeId, userId);
      final challenge =
          state.publicChallenges.where((c) => c.id == challengeId).firstOrNull;
      if (challenge != null) {
        state = state.copyWith(
          myChallenges: [challenge, ...state.myChallenges],
        );
      }
      await loadChallenges();
    } catch (e) {
      debugPrint('Erreur participation défi: $e');
      rethrow;
    }
  }

  Future<void> leaveChallenge(String challengeId) async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      await _repo.leaveChallenge(challengeId, userId);
      state = state.copyWith(
        myChallenges:
            state.myChallenges.where((c) => c.id != challengeId).toList(),
      );
    } catch (e) {
      debugPrint('Erreur départ défi: $e');
      rethrow;
    }
  }

  Future<void> refresh() async {
    await loadChallenges();
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  final notifier = ChallengeNotifier(ChallengeRepository());
  notifier.loadChallenges();
  return notifier;
});

final challengeParticipantsProvider =
    FutureProvider.family<List<ChallengeParticipant>, String>((ref, id) {
  return ChallengeRepository().getParticipants(id);
});

final challengeIsParticipantProvider =
    FutureProvider.family<bool, String>((ref, challengeId) {
  final userId = AppSession.userId;
  if (userId == null) return Future.value(false);
  return ChallengeRepository().isParticipant(challengeId, userId);
});

final challengeMessagesProvider =
    FutureProvider.family<List<ChallengeMessage>, String>((ref, challengeId) {
  return ChallengeRepository().getMessages(challengeId);
});
