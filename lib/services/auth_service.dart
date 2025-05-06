import 'package:flutter_application_2/services/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static int? _currentUserId;

  static int? getCurrentUserId(){
    return _currentUserId;
  }
   static Future<bool> login(String email, String password) async{
      return true;
   }
   static Future<bool> createUser(Map<String, dynamic> user) async {return true;}

   Future<bool> register(String email, String password) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert('users', {'email': email, 'password': password});
      if (id > 0){
        _currentUserId = id;
      }
      return id > 0;
    } catch (e) {
      print(e);
      return false;
    }
  }
  static Future<bool> login2(String email, String password) async {
    try{
      final db = await DatabaseHelper.instance.database;
      final users = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
      if(users.isNotEmpty){
        _currentUserId = users.first['id'] as int?;
      }
      return users.isNotEmpty;
    }catch(e){
      rethrow;
    }
  }
  static void logout(){
    _currentUserId = null;
  }
}