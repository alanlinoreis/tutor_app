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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        studentId   INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT NOT NULL,
        email       TEXT NOT NULL,
        course      TEXT NOT NULL,
        tutorId     INTEGER,
        tutorName   TEXT
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
        enrollmentId       INTEGER PRIMARY KEY AUTOINCREMENT,
        registrationCode   TEXT NOT NULL,
        studentName        TEXT NOT NULL,
        courseName         TEXT NOT NULL,
        enrollmentDate     TEXT NOT NULL,
        status             TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Recria a tabela students sem registrationNumber e com tutorId/tutorName
      await db.execute('DROP TABLE IF EXISTS students');
      await db.execute('''
        CREATE TABLE students (
          studentId   INTEGER PRIMARY KEY AUTOINCREMENT,
          name        TEXT NOT NULL,
          email       TEXT NOT NULL,
          course      TEXT NOT NULL,
          tutorId     INTEGER,
          tutorName   TEXT
        )
      ''');

      // Adiciona registrationCode em enrollments (ignorando erro caso já exista)
      try {
        await db.execute(
          'ALTER TABLE enrollments ADD COLUMN registrationCode TEXT NOT NULL DEFAULT ""',
        );
      } catch (_) {}
    }
  }
}
