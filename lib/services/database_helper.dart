import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static const String _databaseName = "app.db";
  static const int _databaseVersion = 1;

  Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _databaseStatic;
  static Future<Database> get database async {
    _databaseStatic ??= await instance._initDatabase();
    return _databaseStatic!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    try {
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)');
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createUser(String email, String password) async {
    final db = await database;
    try {
      final sql = 'INSERT INTO users (email, password) VALUES (?, ?)';
      return await db.rawInsert(sql, [email, password]);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}