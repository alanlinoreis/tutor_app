import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tutor_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tutors (
        tutorId   INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT NOT NULL,
        phone     TEXT NOT NULL,
        email     TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students (
        studentId            INTEGER PRIMARY KEY AUTOINCREMENT,
        name                 TEXT NOT NULL,
        registrationNumber   TEXT NOT NULL,
        email                TEXT NOT NULL,
        course               TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        courseId      INTEGER PRIMARY KEY AUTOINCREMENT,
        name          TEXT NOT NULL,
        duration      TEXT NOT NULL,
        coordinator   TEXT NOT NULL,
        description   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE enrollments (
        enrollmentId     INTEGER PRIMARY KEY AUTOINCREMENT,
        studentName      TEXT NOT NULL,
        courseName       TEXT NOT NULL,
        enrollmentDate   TEXT NOT NULL,
        status           TEXT NOT NULL
      )
    ''');
  }
}
