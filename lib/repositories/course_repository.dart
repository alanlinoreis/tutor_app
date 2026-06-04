import '../database/app_database.dart';
import '../models/course.dart';

class CourseRepository {
  final _db = AppDatabase.instance;

  Future<int> insert(Course course) async {
    final db = await _db.database;
    return db.insert('courses', course.toMap());
  }

  Future<List<Course>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('courses', orderBy: 'name ASC');
    return maps.map(Course.fromMap).toList();
  }

  Future<int> update(Course course) async {
    final db = await _db.database;
    return db.update(
      'courses',
      course.toMap(),
      where: 'courseId = ?',
      whereArgs: [course.courseId],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('courses', where: 'courseId = ?', whereArgs: [id]);
  }
}
