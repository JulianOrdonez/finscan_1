import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/models/user.dart';
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

  _login() async {
    if (_formKey.currentState!.validate()) {
        try {
            final bool user = await _runLoginInIsolate(
                _emailController.text, _passwordController.text);

            if (!user) {    
                _showErrorSnackBar('Usuario o contraseña incorrectos');
                return;
            }

            // If login is successful, navigate to HomePage
            await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
            );
        } catch (e) {
            print('Login error: $e');
            _showErrorSnackBar('Error de conexion');
        }
    }
  }

    Future<bool> _runLoginInIsolate(String email, String password) async {
        final ReceivePort receivePort = ReceivePort();
        await Isolate.spawn(_loginIsolate, [email, password, receivePort.sendPort]);
        final result = await receivePort.first;
        receivePort.close();
        return result;
    }
    
    static void _loginIsolate(List<dynamic> args) async {
        String email = args[0];
        String password = args[1];
        SendPort sendPort = args[2];
        try {
            final bool success = await AuthService().login(email, password);            
            sendPort.send(success);
        } catch (e) {
            sendPort.send(null);
        }
    }

    void _showErrorSnackBar(String message) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
        );
    }

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