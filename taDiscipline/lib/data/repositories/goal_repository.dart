import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/goal.dart';

class GoalRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Goal>> getGoals(String userId) async {
    final rows = await _db.query('goals',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows.map((j) => Goal.fromJson(j)).toList();
  }

  Future<Goal> getGoal(String goalId) async {
    final row = await _db.querySingle('goals', where: 'id = ?', whereArgs: [goalId]);
    if (row == null) throw Exception('Objectif introuvable');
    return Goal.fromJson(row);
  }

  Future<Goal> createGoal(Goal goal) async {
    await _db.insert('goals', goal.toJson());
    return goal;
  }

  Future<Goal> updateGoal(Goal goal) async {
    await _db.update('goals', goal.toJson(), where: 'id = ?', whereArgs: [goal.id]);
    return goal;
  }

  Future<void> deleteGoal(String goalId) async {
    await _db.delete('goals', where: 'id = ?', whereArgs: [goalId]);
  }

  Future<List<SubTask>> getSubTasks(String goalId) async {
    final rows = await _db.query('subtasks',
        where: 'goal_id = ?', whereArgs: [goalId], orderBy: '"order" ASC');
    return rows.map((j) => SubTask.fromJson(j)).toList();
  }

  Future<SubTask> createSubTask(SubTask task) async {
    await _db.insert('subtasks', task.toJson());
    return task;
  }

  Future<SubTask> updateSubTask(SubTask task) async {
    await _db.update('subtasks', task.toJson(), where: 'id = ?', whereArgs: [task.id]);
    return task;
  }

  Future<void> deleteSubTask(String taskId) async {
    await _db.delete('subtasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<int> getGoalsCount(String userId) async {
    final rows =
        await _db.query('goals', where: 'user_id = ?', whereArgs: [userId], columns: ['id']);
    return rows.length;
  }
}
