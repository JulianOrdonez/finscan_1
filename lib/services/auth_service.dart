import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<User?> registerUser(String name, String email, String password) async {
    final id = await _dbHelper.createUser(name, email, password);
    if (id != null && id > 0) {
        final user = await _dbHelper.getUserById(id);
      return user;
    }
    return null;
  }

  Future<User?> loginUser(String email, String password) async {
    final userExists = await _dbHelper.validateUser(email, password);
    if (userExists) {
      final userId = await _dbHelper.getUserIdByEmail(email);
      if(userId != null){
          await _dbHelper.setCurrentUser(userId);
        final user = await _dbHelper.getUserById(userId);
        return user;
      }
      
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    final userId = await _dbHelper.getCurrentUser();
    if (userId != null) {
      final user = await _dbHelper.getUserById(userId);
      return user;
    }
    return null; 
  }

  Future<void> logoutUser() async {
      await _dbHelper.clearCurrentUser();
  }
}