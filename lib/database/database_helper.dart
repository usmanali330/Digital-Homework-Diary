import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/grade.dart';
import '../models/subject.dart';
import '../models/diary_entry.dart';
import '../models/assignment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color_code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        grade_id INTEGER NOT NULL,
        school_name TEXT,
        school_address TEXT,
        welcome_message TEXT,
        footer_message TEXT,
        teacher_name TEXT,
        principal_name TEXT,
        UNIQUE(date, grade_id),
        FOREIGN KEY (grade_id) REFERENCES grades (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diary_id INTEGER NOT NULL,
        subject_name TEXT NOT NULL,
        task_description TEXT,
        FOREIGN KEY (diary_id) REFERENCES diary_entries (id) ON DELETE CASCADE
      )
    ''');

    // Seed Data
    final grades = ['Prep/KG', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'];
    for (var name in grades) {
      await db.insert('grades', {'name': name});
    }

    final subjects = [
      {'name': 'English', 'color_code': '1E56A0'},
      {'name': 'Math', 'color_code': 'FF8A00'},
      {'name': 'Urdu', 'color_code': '4CAF50'},
      {'name': 'G.K', 'color_code': '9C27B0'},
      {'name': 'C.S', 'color_code': '607D8B'},
      {'name': 'Nazra', 'color_code': 'E91E63'},
      {'name': 'Poem', 'color_code': '795548'},
    ];
    for (var subject in subjects) {
      await db.insert('subjects', subject);
    }
  }

  Future<List<Grade>> getGrades() async {
    final db = await instance.database;
    final result = await db.query('grades');
    return result.map((json) => Grade.fromMap(json)).toList();
  }

  Future<List<Subject>> getSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects');
    return result.map((json) => Subject.fromMap(json)).toList();
  }

  Future<DiaryEntry?> getDiaryByDateAndGrade(String date, int gradeId) async {
    final db = await instance.database;
    final diaryResult = await db.query(
      'diary_entries',
      where: 'date = ? AND grade_id = ?',
      whereArgs: [date, gradeId],
    );

    if (diaryResult.isEmpty) return null;

    final diaryMap = Map<String, dynamic>.from(diaryResult.first);
    final diaryId = diaryMap['id'] as int;

    final assignmentsResult = await db.query(
      'assignments',
      where: 'diary_id = ?',
      whereArgs: [diaryId],
    );

    final assignments = assignmentsResult.map((json) => Assignment.fromMap(json)).toList();
    return DiaryEntry.fromMap(diaryMap, assignments: assignments);
  }

  Future<int> insertDiary(DiaryEntry diary, List<Assignment> assignments) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final diaryId = await txn.insert('diary_entries', diary.toMap());
      for (var assignment in assignments) {
        await txn.insert('assignments', assignment.copyWith(diaryId: diaryId).toMap());
      }
      return diaryId;
    });
  }

  Future<int> updateDiary(DiaryEntry diary, List<Assignment> assignments) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      await txn.update(
        'diary_entries',
        diary.toMap(),
        where: 'id = ?',
        whereArgs: [diary.id],
      );
      await txn.delete('assignments', where: 'diary_id = ?', whereArgs: [diary.id]);
      for (var assignment in assignments) {
        await txn.insert('assignments', assignment.copyWith(diaryId: diary.id).toMap());
      }
      return diary.id!;
    });
  }

  Future<int> deleteDiary(int id) async {
    final db = await instance.database;
    return await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getDiaryDates(int gradeId) async {
    final db = await instance.database;
    final result = await db.query(
      'diary_entries',
      columns: ['date'],
      where: 'grade_id = ?',
      whereArgs: [gradeId],
    );
    return result.map((json) => json['date'] as String).toList();
  }
}
