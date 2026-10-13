import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prayer_note.dart';
import '../models/quran_bookmark.dart';
import '../models/dhikr_goal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('praynow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE prayer_notes (
        id $idType,
        title $textType,
        content $textType,
        category $textType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE quran_bookmarks (
        id $idType,
        surahName $textType,
        surahNumber $intType,
        verseNumber $intType,
        verseText $textType,
        notes TEXT,
        createdAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE dhikr_goals (
        id $idType,
        dhikrName $textType,
        targetCount $intType,
        currentCount $intType,
        startDate $textType,
        completionDate TEXT,
        isCompleted $intType
      )
    ''');
  }

  // ========== PRAYER NOTES CRUD ==========
  
  Future<int> createNote(PrayerNote note) async {
    final db = await database;
    return await db.insert('prayer_notes', note.toMap());
  }

  Future<PrayerNote?> readNote(int id) async {
    final db = await database;
    final maps = await db.query(
      'prayer_notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PrayerNote.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PrayerNote>> readAllNotes() async {
    final db = await database;
    const orderBy = 'updatedAt DESC';
    final result = await db.query('prayer_notes', orderBy: orderBy);
    return result.map((json) => PrayerNote.fromMap(json)).toList();
  }

  Future<List<PrayerNote>> readNotesByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'prayer_notes',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updatedAt DESC',
    );
    return result.map((json) => PrayerNote.fromMap(json)).toList();
  }

  Future<int> updateNote(PrayerNote note) async {
    final db = await database;
    return await db.update(
      'prayer_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'prayer_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== QURAN BOOKMARKS CRUD ==========
  
  Future<int> createBookmark(QuranBookmark bookmark) async {
    final db = await database;
    return await db.insert('quran_bookmarks', bookmark.toMap());
  }

  Future<QuranBookmark?> readBookmark(int id) async {
    final db = await database;
    final maps = await db.query(
      'quran_bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QuranBookmark.fromMap(maps.first);
    }
    return null;
  }

  Future<List<QuranBookmark>> readAllBookmarks() async {
    final db = await database;
    const orderBy = 'createdAt DESC';
    final result = await db.query('quran_bookmarks', orderBy: orderBy);
    return result.map((json) => QuranBookmark.fromMap(json)).toList();
  }

  Future<List<QuranBookmark>> readBookmarksBySurah(int surahNumber) async {
    final db = await database;
    final result = await db.query(
      'quran_bookmarks',
      where: 'surahNumber = ?',
      whereArgs: [surahNumber],
      orderBy: 'verseNumber ASC',
    );
    return result.map((json) => QuranBookmark.fromMap(json)).toList();
  }

  Future<int> updateBookmark(QuranBookmark bookmark) async {
    final db = await database;
    return await db.update(
      'quran_bookmarks',
      bookmark.toMap(),
      where: 'id = ?',
      whereArgs: [bookmark.id],
    );
  }

  Future<int> deleteBookmark(int id) async {
    final db = await database;
    return await db.delete(
      'quran_bookmarks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== DHIKR GOALS CRUD ==========
  
  Future<int> createGoal(DhikrGoal goal) async {
    final db = await database;
    return await db.insert('dhikr_goals', goal.toMap());
  }

  Future<DhikrGoal?> readGoal(int id) async {
    final db = await database;
    final maps = await db.query(
      'dhikr_goals',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DhikrGoal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DhikrGoal>> readAllGoals() async {
    final db = await database;
    const orderBy = 'startDate DESC';
    final result = await db.query('dhikr_goals', orderBy: orderBy);
    return result.map((json) => DhikrGoal.fromMap(json)).toList();
  }

  Future<List<DhikrGoal>> readActiveGoals() async {
    final db = await database;
    final result = await db.query(
      'dhikr_goals',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'startDate DESC',
    );
    return result.map((json) => DhikrGoal.fromMap(json)).toList();
  }

  Future<List<DhikrGoal>> readCompletedGoals() async {
    final db = await database;
    final result = await db.query(
      'dhikr_goals',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completionDate DESC',
    );
    return result.map((json) => DhikrGoal.fromMap(json)).toList();
  }

  Future<int> updateGoal(DhikrGoal goal) async {
    final db = await database;
    return await db.update(
      'dhikr_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'dhikr_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== STATISTICS ==========
  
  Future<int> getTotalNotesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM prayer_notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalBookmarksCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM quran_bookmarks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalDhikrCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(currentCount) FROM dhikr_goals');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedGoalsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM dhikr_goals WHERE isCompleted = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}