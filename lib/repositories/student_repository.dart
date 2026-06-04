import '../database/app_database.dart';
import '../models/student.dart';

class StudentRepository {
  final _db = AppDatabase.instance;

  Future<int> insert(Student student) async {
    final db = await _db.database;
    return db.insert('students', student.toMap());
  }

  Future<List<Student>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('students', orderBy: 'name ASC');
    return maps.map(Student.fromMap).toList();
  }

  Future<int> update(Student student) async {
    final db = await _db.database;
    return db.update(
      'students',
      student.toMap(),
      where: 'studentId = ?',
      whereArgs: [student.studentId],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('students', where: 'studentId = ?', whereArgs: [id]);
  }
}
