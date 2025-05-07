import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<bool> registerUser(
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

  Future<User?> loginUser(String email, String password) async {
    try {
      final user = await _databaseHelper.getUserByEmail(email);
      if (user != null && user.password == password) {
        return user; // Return the user object if login is successful
      }
      return null; // Return null if login fails
    } catch (e) {
      print("Error logging in user: $e");
      return null;
    }
  }

  Future<bool> logoutUser() async {
    // No specific action needed for local logout, just clear session data if applicable
    // Here you could clear user preferences, tokens, etc.
    return true; // Assuming logout is always successful in this context
  }

  Future<bool> validateUser(String email, String password) async {
    try {
      final user = await _databaseHelper.getUserByEmail(email);
      return user != null && user.password == password;
    } catch (e) {
      print("Error validating user: $e");
      return false;
    }
  }
}