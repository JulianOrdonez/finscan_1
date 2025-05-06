import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _createUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final name = _nameController.text;
        final email = _emailController.text;
        final password = _passwordController.text;
        User newUser = User(id: 0, name: name, email: email, password: password);

        bool isCreated = await _authService.createUser(newUser);

        if (isCreated) {
          bool logged = await _authService.login(
              _emailController.text, _passwordController.text);
          if (logged) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  HomePage()),
            );
          }
        } else {
          _showErrorSnackBar('Error al registrarse, usuario ya existe.', context);
        }
      } catch (error) {
        print('Firebase Error: $error');
        _showErrorSnackBar('Error al registrarse', context);
      }
    }
  }

  void _showErrorSnackBar(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateTo