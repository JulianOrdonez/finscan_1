import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DatabaseHelper _databaseHelper;

  int? _currentUserId;

  AuthService({required DatabaseHelper databaseHelper}) : _databaseHelper = databaseHelper;
  
  Future<bool> register(
      String name, String email, String password) async {
    try {
      // Check if a user with the same email already exists
      final existingUser = await _databaseHelper.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }
      // Create a new user object
      final user = User(
          name: name, email: email, password: password, id: null);
      // Insert the user into the database
      final result = await _databaseHelper.createUser(user);
      return result; // Return true if successful, false otherwise
    } catch (e) {
      print("Error registering user: $e");
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final user = await _databaseHelper.getUserByEmail(email);
      if (user != null && user.password == password) {
        _currentUserId = user.id;
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        return true; // Return true if login is successful
      }
 return false; // Return false if login fails
    } catch (e) {
      print("Error logging in user: $e");
 return false;
    }
  }

  Future<String> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Please fill all the fields');
    } else {
      return email;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<int?> getCurrentUserId() async {
    // In a real application, you would fetch the user ID from a stored token or session
    return _currentUserId;
  }
  Future<bool> validatePassword(String email, String password) async {
    try {
     final user = await _databaseHelper.getUserByEmail(email);
      return user != null && user.password == password;
    } catch (e) {
      print("Error validating password: $e");
 return false;
    }
  }
  Future<bool> checkLoginStatus() async {
    return isLoggedIn();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
}