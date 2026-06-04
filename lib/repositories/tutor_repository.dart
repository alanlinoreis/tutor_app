import '../database/app_database.dart';
import '../models/tutor.dart';

class TutorRepository {
  final _db = AppDatabase.instance;

  Future<int> insert(Tutor tutor) async {
    final db = await _db.database;
    return db.insert('tutors', tutor.toMap());
  }

  Future<List<Tutor>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('tutors', orderBy: 'name ASC');
    return maps.map(Tutor.fromMap).toList();
  }

  Future<int> update(Tutor tutor) async {
    final db = await _db.database;
    return db.update(
      'tutors',
      tutor.toMap(),
      where: 'tutorId = ?',
      whereArgs: [tutor.tutorId],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('tutors', where: 'tutorId = ?', whereArgs: [id]);
  }
}
