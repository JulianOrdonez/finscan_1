import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finscan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final database = await openDatabase(path, version: 1, onCreate: _createDB);
    await _createDB(database, 1);
    return database;
  }

  Future _createDB(Database db, int version) async {
    await db.execute("""
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  receiptPath TEXT,
  userId INTEGER NOT NULL
)""");
    await db.execute("""
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL
)""");
  }

  // Expenses methods
  Future<int> createExpense(Expense expense) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return 0;
    final expenseWithUser = expense.copyWith(userId: currentUser);

    final db = await instance.database;
    return await db.insert('expenses', expenseWithUser.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    final int? currentUserId = await getCurrentUser();

    if (currentUserId == null) return [];

    return result
        .where((expense) => expense['userId'] == currentUserId)
        .map((map) => Expense.fromMap(map)).toList();
  }

  Future<Expense?> getExpense(int id) async {
    final db = await instance.database;
    final maps = await db.query('expenses', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    }

    Future<int> deleteExpense(int id) async {
      final db = await instance.database;
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    }

    // User methods

    Future<int> createUser(String email, String password) async {
      final db = await instance.database;
      final user = {
        'email': email,
        'password': password,
      };
      return await db.insert('users', user);
    }

    Future<bool> validateUser(String email, String password) async {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      return result.isNotEmpty;
    }

    Future<bool> userExists(String email) async {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty;
    }

    Future<User?> getUserById(int id) async{
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

     if (maps.isNotEmpty) {
        return User(
          id: maps.first['id'] as int?,
          email: maps.first['email'] as String,
          password: maps.first['password'] as String,
      );
    }
    return null;
  }
    // current user methods
    Future<void> setCurrentUser(int userId) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', userId);
    }

    Future<int?> getCurrentUser() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('currentUserId');
    }

    Future<void> clearCurrentUser() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUserId');
    }
    Future<int?> getUserIdByEmail(String email) async {
      final db = await instance.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        return result.first['id'] as int?;
      }

      return null;
    }
    
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
