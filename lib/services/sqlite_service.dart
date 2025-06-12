import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/message_model.dart';

class SQLiteService {
  static final SQLiteService _instance = SQLiteService._internal();
  factory SQLiteService() => _instance;
  SQLiteService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chat_app.db');

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT,
        receiver TEXT,
        content TEXT,
        timestamp TEXT,
        isSent INTEGER
      )
    ''');
  }

  Future<void> insertMessage(MessageModel message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ambil pesan antara dua user (bi-directional)
  Future<List<MessageModel>> getMessages(String userA, String userB) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: '(sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?)',
      whereArgs: [userA, userB, userB, userA],
      orderBy: 'timestamp ASC',
    );

    return result.map((map) => MessageModel.fromMap(map)).toList();
  }

  /// (Opsional) Clear chat history
  Future<void> clearMessages() async {
    final db = await database;
    await db.delete('messages');
  }
}
