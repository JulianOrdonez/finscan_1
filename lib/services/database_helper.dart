import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static const _databaseName = "ExpenseTracker.db";
  static const _databaseVersion = 1;

  static const tableUsers = 'users';
  static const tableExpenses = 'expenses';

  // User table columns
  static const columnUserId = 'id';
  static const columnUserName = 'name';
  static const columnUserEmail = 'email';
  static const columnUserPassword = 'password';

  // Expense table columns
  static const columnExpenseId = 'id';
  static const columnExpenseAmount = 'amount';
  static const columnExpenseCategory = 'category';
  static const columnExpenseDate = 'date';
  static const columnExpenseDescription = 'description';
  static const columnExpenseUserId = 'user_id';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserName TEXT NOT NULL,
        $columnUserEmail TEXT NOT NULL UNIQUE,
        $columnUserPassword TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableExpenses (
        $columnExpenseId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnExpenseAmount REAL NOT NULL,
        $columnExpenseCategory TEXT NOT NULL,
        $columnExpenseDate TEXT NOT NULL,
        $columnExpenseDescription TEXT,
        $columnExpenseUserId INTEGER NOT NULL,
        FOREIGN KEY ($columnExpenseUserId) REFERENCES $tableUsers($columnUserId) ON DELETE CASCADE
      )
    ''');
  }

  // User Methods
  Future<bool> insertUser(User user) async {
    Database db = await instance.database;
    try {
      await db.insert(tableUsers, user.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getUser(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUserEmail = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<bool> updateUser(User user) async {
    Database db = await instance.database;
    int result = await db.update(tableUsers, user.toJson(),
        where: '$columnUserId = ?', whereArgs: [user.id]);
    return result > 0;
  }

  Future<bool> deleteUser(int id) async {
    Database db = await instance.database;
    int result =
        await db.delete(tableUsers, where: '$columnUserId = ?', whereArgs: [id]);
    return result > 0;
  }

  // Expense Methods
  Future<bool> insertExpense(Expense expense) async {
    Database db = await instance.database;
    try {
      await db.insert(tableExpenses, expense.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Expense>> getExpenses(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableExpenses,
      where: '$columnExpenseUserId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Expense.fromJson(maps[i]);
    });
  }

  Future<bool> updateExpense(Expense expense) async {
    Database db = await instance.database;
    int result = await db.update(tableExpenses, expense.toJson(),
        where: '$columnExpenseId = ?', whereArgs: [expense.id]);
    return result > 0;
  }

  Future<bool> deleteExpense(int id) async {
    Database db = await instance.database;
    int result = await db
        .delete(tableExpenses, where: '$columnExpenseId = ?', whereArgs: [id]);
    return result > 0;
  }
  Future<List<Expense>> getAllExpenses() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableExpenses);
    return List.generate(maps.length, (i) {
      return Expense.fromJson(maps[i]);
    });
  }
}