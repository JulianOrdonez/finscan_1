import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int? _currentUserId;

  int? getCurrentUserId() {
    return _currentUserId;
  }

  Future<int> createUser(String email, String password) async {
    try {
      final id = await _dbHelper.insertUser(email, password);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<int?> login(String email, String password) async {    
   try {
      final List<Map<String, dynamic>> users = await _dbHelper.getDatabase().query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (users.isNotEmpty) {
        _currentUserId = users.first['id'] as int;
        return _currentUserId;
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