import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_application_2/models/expense.dart';
import 'package:flutter_application_2/models/user.dart';
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
          await db.execute(
              'CREATE TABLE current_user (id INTEGER)');
          await db.execute(
              'CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, amount REAL, category TEXT, date TEXT, receiptPath TEXT)');
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createUser(String email, String password) async {
    var db = await DatabaseHelper.database;
    try {
      final sql = 'INSERT INTO users (email, password) VALUES (?, ?)';
      return await db.rawInsert(sql, [email, password]);
    } catch (e) {
      print(e);
      rethrow;
    }}
  
    Future<int?> getCurrentUser() async {
      var db = await DatabaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('current_user');
      if (maps.isNotEmpty) {
        return maps.first['id'] as int;
      }
      return null;
    }
  
    Future<User?> getUserById(int id) async {
      var db = await DatabaseHelper.database;
      try {
        final List<Map<String, dynamic>> maps = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [id],
        );
  
        if (maps.isNotEmpty) {
          return User(
            id: maps.first['id'] as int,
            email: maps.first['email'] as String,
            password: "",
          );
        }
        return null;
      } catch (e) {
        return null;
      }
    }
  
    Future<void> clearCurrentUser() async {
      var db = await DatabaseHelper.database;
      await db.execute('DELETE FROM current_user');
    }
  
    Future<List<Expense>> getExpenses() async {
      var db = await DatabaseHelper.database;
      try {
        var result = await db.query('expenses');
  
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
        }).toList() ;
      }catch (e) {
        rethrow;
      }
    }
  
    Future<void> deleteExpense(int id) async {
      var db = await DatabaseHelper.database;
      await db.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  
    Future<int> createExpense(Expense expense) async {
      var db = await DatabaseHelper.database;
      try {
        final sql ='INSERT INTO expenses (title, description, amount, category, date, receiptPath) VALUES (?, ?, ?, ?, ?, ?)';
        return await db.rawInsert(sql, [
          expense.title,
          expense.description,
          expense.amount,
          expense.category,
          expense.date.toIso8601String(), // Convert DateTime to String
          expense.receiptPath
        ]);
      } catch (e) {
        print(e);
        rethrow;
      }
    }
  
    Future<void> updateExpense(Expense expense) async {
      var db = await DatabaseHelper.database;
      try {
        final sql = 'UPDATE expenses SET title = ?, description = ?, amount = ?, category = ?, date = ?, receiptPath = ? WHERE id = ?';
        await db.rawUpdate(sql, [expense.title, expense.description, expense.amount, expense.category, expense.date.toIso8601String(), expense.receiptPath, expense.id]);
       } catch (e) {
        print(e);
        rethrow;
      }
  }
}