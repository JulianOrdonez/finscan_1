import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> registerUser(String email, String password) async {
    try {
      final id = await _dbHelper.createUser(email, password);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    var db = await _dbHelper.database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        'users', 
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        int userId = result.first['id'] as int;
        await db.insert('current_user', {'id': userId});
        return User(
          id: userId,
          email: result.first['email'] as String,
          password: '',
        );
        
      } else {
        return null;
      }
    } catch(e){
      print(e);
      return null;
    }
  }

  Future<void> logout() async {
    await _dbHelper.clearCurrentUser();
  }

}