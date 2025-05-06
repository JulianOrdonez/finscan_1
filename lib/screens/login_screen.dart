import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Handles the login process.
  ///
  /// Validates the form and attempts to log in the user with the provided
  /// email and password. Navigates to the home screen on successful login
  /// or shows an error message on failure.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _authService
          .login(_emailController.text, _passwordController.text)
          .then((isLogged) {
        if (isLogged) {
          _navigateToHome();
        } else {
          _showErrorSnackBar('Usuario o contraseña incorrectos');
        }
      });
    } catch (e) {
      _showErrorSnackBar('Error de conexion');
      }
  }

  /// Navigates to the home screen.
  ///
  /// Uses [Navigator] to replace the current route with the [HomePage].
  void _navigateToHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
      );
  }

  /// Navigates to the registration screen.
  ///
  /// Pushes the [RegisterScreen] route onto the navigator, allowing the user
  /// to create a new account.
  void _navigateToRegister() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su correo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _navigateToRegister,
                child: const Text('¿No tienes una cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
