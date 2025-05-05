import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> registerUser(String email, String password) async {
    try {
      final id = await DatabaseHelper.instance.createUser(email, password);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginUser(String email, String password) async {
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