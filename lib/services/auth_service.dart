import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {

  static Future<int?> getCurrentUserId() async {
    return await DatabaseHelper.getCurrentUserId();
  }

  static Future<bool> login(String email, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      final users = await db.query('users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password]);
      if (users.isNotEmpty) {
        int userId = users.first['id'] as int;
        await DatabaseHelper.instance.setCurrentUser(userId);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> createUser(Map<String, dynamic> user) async {
    try {
      final id = await DatabaseHelper.instance
          .insertUser(user['email'], user['password']);
      if (id > 0) {
        await DatabaseHelper.instance.setCurrentUser(id);
      }
      return id > 0;
    } catch (e) {
      rethrow;
    }
  }

    static Future<void> logout() async {
    try {
      await DatabaseHelper.instance.clearCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

}