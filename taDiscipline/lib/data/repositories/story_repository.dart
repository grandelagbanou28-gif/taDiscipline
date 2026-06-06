import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/story.dart';

class StoryRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Story>> getActiveStories(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await _db.query('stories',
        where: 'user_id = ? AND expires_at >= ?',
        whereArgs: [userId, now],
        orderBy: 'created_at DESC');
    return rows.map((j) => Story.fromJson(j)).toList();
  }

  Future<List<Story>> getStoriesByUser(String userId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final rows = await _db.query('stories',
        where: 'user_id = ? AND expires_at >= ?',
        whereArgs: [userId, now],
        orderBy: 'created_at DESC');
    return rows.map((j) => Story.fromJson(j)).toList();
  }

  Future<Story> createStory(Story story) async {
    await _db.insert('stories', story.toJson());
    return story;
  }

  Future<void> deleteStory(String storyId) async {
    await _db.delete('stories', where: 'id = ?', whereArgs: [storyId]);
  }

  Future<void> cleanupExpired() async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.delete('stories', where: 'expires_at < ?', whereArgs: [now]);
  }
}
