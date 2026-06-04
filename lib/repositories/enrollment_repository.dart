import '../database/app_database.dart';
import '../models/enrollment.dart';

class EnrollmentRepository {
  final _db = AppDatabase.instance;

  Future<int> insert(Enrollment enrollment) async {
    final db = await _db.database;
    return db.insert('enrollments', enrollment.toMap());
  }

  Future<List<Enrollment>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('enrollments', orderBy: 'studentName ASC');
    return maps.map(Enrollment.fromMap).toList();
  }

  Future<int> update(Enrollment enrollment) async {
    final db = await _db.database;
    return db.update(
      'enrollments',
      enrollment.toMap(),
      where: 'enrollmentId = ?',
      whereArgs: [enrollment.enrollmentId],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('enrollments', where: 'enrollmentId = ?', whereArgs: [id]);
  }
}
