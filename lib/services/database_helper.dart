import 'dart:io';

import 'package:flutter_application_2/models/expense.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const String _databaseName = "app.db";
  static const int _databaseVersion = 2;

  Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (instance._database == null) {
      instance._database = await instance._initDatabase();
    }
    return instance._database!;
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
          await db.execute('CREATE TABLE current_user (id INTEGER)');
          await db.execute(
              'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT, description TEXT, amount REAL, category TEXT, date TEXT, receiptPath TEXT,'
              'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE)');
          await db.execute(
              'CREATE TABLE current_user (id INTEGER)');

          },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            // Add user_id column
            await db.execute(
                'ALTER TABLE expenses ADD COLUMN user_id INTEGER');

            // Update existing records with user_id
            List<Map> expenses = await db.query('expenses');
            if (expenses.isNotEmpty) {
              int? userId = await getCurrentUser();
              if (userId != null) {
                for (var expense in expenses) {
                  await db.update('expenses', {'user_id': userId},
                      where: 'id = ?', whereArgs: [expense['id']]);
                }
              }
            }
            await db.execute('CREATE TABLE IF NOT EXISTS expenses_temp AS SELECT id, title, description, amount, category, date, receiptPath, user_id FROM expenses');
            await db.execute('DROP TABLE expenses');
            await db.execute('ALTER TABLE expenses_temp RENAME TO expenses');
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> insertUser(String email, String password) async {
    try {
      var db = await database;
      final sql = 'INSERT INTO users (email, password) VALUES (?, ?)';
      return await db.rawInsert(sql, [email, password]);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
  


    
      Future<int?> getCurrentUser() async {
      try{
        var db = await database;
        final List<Map<String, dynamic>> maps = await db.query('current_user');
        if (maps.isNotEmpty) {
          return maps.first['id'] as int;
        }
        return null;
      } catch(e){
        rethrow;
      }
    }
  
  Future<User?> getUserById(int id) async {
    try {
      var db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return User(
          id: maps.first['id'] as int,
          email: maps.first['email'] as String,
          password: maps.first['password'] as String,
        );
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> clearCurrentUser() async {
    var db = await database;
    await db.execute('DELETE FROM current_user');
  }

  Future<List<Expense>> getAllExpenses(int userId) async {
    try {
      var db = await database;

      var result = await db.query(
        'expenses',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result.map((map) {
        return Expense(
          id: map['id'] as int?,
          title: map['title'] as String,
          description: map['description'] as String,
          amount: map['amount'] as double,
          category: map['category'] as String,
          date: DateTime.parse(map['date'] as String),
          receiptPath: map['receiptPath'] as String?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
      Future<void> deleteExpense(int id) async {
      var db = await database;
      await db.delete(
        'expenses',
        where: 'id = ? ',
        whereArgs: [id],
      );
    }
    Future<void> setCurrentUser(int userId) async {
      var db = await database;
      await db.delete('current_user');
      await db.insert('current_user', {'id': userId});
    } 

  Future<int> insertExpense(Expense expense) async {
    try {
      var db = await database;
      int? currentUserId = await getCurrentUser();
      if (currentUserId == null) {
        throw Exception("No user is currently logged in.");
      }

      final sql =
          'INSERT INTO expenses (title, description, amount, category, date, receiptPath, user_id) VALUES (?, ?, ?, ?, ?, ?, ?)';
      return await db.rawInsert(sql, [
        expense.title,
        expense.description,
        expense.amount,
        expense.category,
        expense.date.toIso8601String(), // Convert DateTime to String
        expense.receiptPath,
        currentUserId
      ]);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> updateExpense(Expense expense) async {
      var db = await database;
      try {
        final sql = 'UPDATE expenses SET title = ?, description = ?, amount = ?, category = ?, date = ?, receiptPath = ? WHERE id = ?';
        await db.rawUpdate(sql, [expense.title, expense.description, expense.amount, expense.category, expense.date.toIso8601String(), expense.receiptPath, expense.id]);
       } catch (e) {
        print(e);
        rethrow;
      }
  }
}