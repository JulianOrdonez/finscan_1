import 'package:flutter_application_2/models/user.dart';
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
      List<Map<String, dynamic>> result = await _dbHelper.query(
        'users', 
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );

      if (result.isNotEmpty) {
        _currentUserId = result.first['id'] as int;
        await db.insert('current_user', {'id': _currentUserId});
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