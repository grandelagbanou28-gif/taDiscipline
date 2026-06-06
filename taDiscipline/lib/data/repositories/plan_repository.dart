import 'dart:convert';
import 'package:apex/data/local/local_database.dart';
import 'package:apex/data/models/plan.dart';

class PlanRepository {
  final LocalDatabase _db = LocalDatabase();

  Future<List<Plan>> getPlans(
    String userId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var where = 'user_id = ?';
    final args = <dynamic>[userId];
    if (from != null) {
      where += ' AND date >= ?';
      args.add(from.toIso8601String().split('T')[0]);
    }
    if (to != null) {
      where += ' AND date <= ?';
      args.add(to.toIso8601String().split('T')[0]);
    }
    final rows =
        await _db.query('plans', where: where, whereArgs: args, orderBy: 'date DESC');
    return rows.map((j) => _rowToPlan(j)).toList();
  }

  Future<Plan> getPlanByDate(String userId, DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final row = await _db.querySingle('plans',
        where: 'user_id = ? AND date = ?', whereArgs: [userId, dateStr]);
    if (row == null) {
      return Plan(id: '', userId: userId, date: date, createdAt: DateTime.now());
    }
    return _rowToPlan(row);
  }

  Future<Plan> savePlan(Plan plan) async {
    await _db.insert('plans', _planToRow(plan));
    return plan;
  }

  Future<void> deletePlan(String planId) async {
    await _db.delete('plans', where: 'id = ?', whereArgs: [planId]);
  }

  Plan _rowToPlan(Map<String, dynamic> row) {
    final tasks = row['tasks'];
    if (tasks is String) row['tasks'] = jsonDecode(tasks);
    return Plan.fromJson(row);
  }

  Map<String, dynamic> _planToRow(Plan plan) {
    final json = plan.toJson();
    json['tasks'] = jsonEncode(json['tasks']);
    return json;
  }
}
