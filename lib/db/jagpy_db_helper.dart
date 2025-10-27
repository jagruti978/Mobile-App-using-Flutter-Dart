import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class JagpyDbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }
  initDB() async {
    String path = join(await getDatabasesPath(), 'jagpy.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE lessons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        module INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_text TEXT,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_answer_index INTEGER,
        module INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        lesson_id INTEGER,
        is_completed INTEGER
      )
    ''');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT');
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE questions ADD COLUMN correct_answer_index INTEGER');
      } catch (e) {
        print('Column already exists: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllLessons() async {
    final dbClient = await db;
    return await dbClient.query('lessons', orderBy: 'module ASC');
  }

  Future<List<Map<String, dynamic>>> getLessonsByModule(int module) async {
    final dbClient = await db;
    return await dbClient.query(
      'lessons',
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'id ASC',
    );
  }

  Future<int> insertLesson(String title, String content, int module) async {
    final dbClient = await db;
    return await dbClient.insert(
      'lessons',
      {'title': title, 'content': content, 'module': module},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateLesson(int id, String title, String content, int module) async {
    final dbClient = await db;
    return await dbClient.update(
      'lessons',
      {'title': title, 'content': content, 'module': module},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLesson(int id) async {
    final dbClient = await db;
    return await dbClient.delete('lessons', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    final dbClient = await db;
    final rawQuestions = await dbClient.query('questions', orderBy: 'module ASC, id ASC');
    return List<Map<String, dynamic>>.from(rawQuestions);
  }

  Future<List<Map<String, dynamic>>> getQuestionsByModule(int module) async {
    final dbClient = await db;
    final rawQuestions = await dbClient.query(
      'questions',
      where: 'module = ?',
      whereArgs: [module],
      orderBy: 'id ASC',
    );
    return List<Map<String, dynamic>>.from(rawQuestions);
  }

  Future<int> insertQuestion({
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required int correctAnswerIndex,
    required int module,
  }) async {
    final dbClient = await db;
    return await dbClient.insert('questions', {
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_answer_index': correctAnswerIndex,
      'module': module,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateQuestion(int id,
      {required String questionText,
        required String optionA,
        required String optionB,
        required String optionC,
        required String optionD,
        required int correctAnswerIndex,
        required int module}) async {
    final dbClient = await db;
    return await dbClient.update(
      'questions',
      {
        'question_text': questionText,
        'option_a': optionA,
        'option_b': optionB,
        'option_c': optionC,
        'option_d': optionD,
        'correct_answer_index': correctAnswerIndex,
        'module': module,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final dbClient = await db;
    return await dbClient.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final dbClient = await db;
    final res = await dbClient.query(
      "users",
      where: "username = ?",
      whereArgs: [username],
      limit: 1,
    );
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<void> markLessonCompleted(int userId, int lessonId) async {
    final dbClient = await db;
    final res = await dbClient.query(
      'progress',
      where: 'user_id = ? AND lesson_id = ?',
      whereArgs: [userId, lessonId],
    );

    if (res.isEmpty) {
      await dbClient.insert('progress', {
        'user_id': userId,
        'lesson_id': lessonId,
        'is_completed': 1,
      });
    } else {
      await dbClient.update(
        'progress',
        {'is_completed': 1},
        where: 'user_id = ? AND lesson_id = ?',
        whereArgs: [userId, lessonId],
      );
    }
  }

  Future<bool> isModuleCompleted(int userId, int module) async {
    final dbClient = await db;
    final total = Sqflite.firstIntValue(await dbClient.rawQuery(
      'SELECT COUNT(*) FROM lessons WHERE module = ?',
      [module],
    ))!;
    final completed = Sqflite.firstIntValue(await dbClient.rawQuery(
      '''
    SELECT COUNT(*) FROM lessons l
    JOIN progress p ON l.id = p.lesson_id
    WHERE l.module = ? AND p.user_id = ? AND p.is_completed = 1
    ''',
      [module, userId],
    ))!;
    return total > 0 && total == completed;
  }
}
