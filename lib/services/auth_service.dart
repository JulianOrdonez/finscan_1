import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int? _currentUserId;

  int? getCurrentUserId() {
    return _currentUserId;
  }

  Future<bool> createUser(String email, String password) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert('users', {'email': email, 'password': password});
      return id > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }

   Future<bool> login(String email, String password) async {
    try{
      final db = await _dbHelper.database;
      final users = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
      return users.isNotEmpty;
    }catch(e){
      rethrow;
    }
  }
}