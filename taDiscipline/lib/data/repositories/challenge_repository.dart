import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/challenge.dart';
import 'package:uuid/uuid.dart';

class ChallengeRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Challenge>> getPublicChallenges() async {
    final rows = await _db.query('challenges',
        where: 'is_public = ? AND status = ?',
        whereArgs: [1, 'active'],
        orderBy: 'created_at DESC');
    return rows.map((j) => Challenge.fromJson(j)).toList();
  }

  Future<List<Challenge>> getMyChallenges(String userId) async {
    final participantRows = await _db.query('challenge_participants',
        where: 'user_id = ?', whereArgs: [userId], columns: ['challenge_id']);
    final ids = participantRows.map((e) => e['challenge_id'] as String).toList();
    if (ids.isEmpty) return [];
    final placeholders = ids.map((_) => '?').join(',');
    final rows = await _db.query('challenges',
        where: 'id IN ($placeholders)', whereArgs: ids, orderBy: 'created_at DESC');
    return rows.map((j) => Challenge.fromJson(j)).toList();
  }

  Future<List<Challenge>> getCreatedChallenges(String userId) async {
    final rows = await _db.query('challenges',
        where: 'creator_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows.map((j) => Challenge.fromJson(j)).toList();
  }

  Future<Challenge> createChallenge(Challenge challenge) async {
    await _db.insert('challenges', challenge.toJson());
    return challenge;
  }

  Future<void> joinChallenge(String challengeId, String userId) async {
    await _db.insert('challenge_participants', {
      'id': const Uuid().v4(),
      'challenge_id': challengeId,
      'user_id': userId,
      'progress': 0.0,
      'joined_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> leaveChallenge(String challengeId, String userId) async {
    await _db.delete('challenge_participants',
        where: 'challenge_id = ? AND user_id = ?', whereArgs: [challengeId, userId]);
  }

  Future<void> updateProgress(String challengeId, String userId, double progress) async {
    await _db.update('challenge_participants', {'progress': progress},
        where: 'challenge_id = ? AND user_id = ?', whereArgs: [challengeId, userId]);
  }

  Future<List<ChallengeParticipant>> getParticipants(String challengeId) async {
    final rows = await _db.query('challenge_participants',
        where: 'challenge_id = ?', whereArgs: [challengeId], orderBy: 'progress DESC');
    return rows.map((j) => ChallengeParticipant.fromJson(j)).toList();
  }

  Future<int> getParticipantsCount(String challengeId) async {
    final rows = await _db.query('challenge_participants',
        where: 'challenge_id = ?', whereArgs: [challengeId], columns: ['id']);
    return rows.length;
  }

  Future<bool> isParticipant(String challengeId, String userId) async {
    final row = await _db.querySingle('challenge_participants',
        where: 'challenge_id = ? AND user_id = ?', whereArgs: [challengeId, userId]);
    return row != null;
  }

  Future<List<ChallengeMessage>> getMessages(String challengeId, {int limit = 50}) async {
    final rows = await _db.query('challenge_messages',
        where: 'challenge_id = ?',
        whereArgs: [challengeId],
        orderBy: 'created_at ASC',
        limit: limit);
    return rows.map((j) => ChallengeMessage.fromJson(j)).toList();
  }

  Future<ChallengeMessage> sendMessage(ChallengeMessage message) async {
    await _db.insert('challenge_messages', message.toJson());
    return message;
  }
}
