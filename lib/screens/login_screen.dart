import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../language_provider.dart';
import 'home_page.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getTranslation('login')),
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
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Email'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider
                        .getTranslation('Por favor, ingrese su correo electrónico');
                  }
                  if (!value.contains('@')) {
                    return languageProvider.getTranslation(
                        'Por favor, ingrese un correo electrónico válido');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Password'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider
                        .getTranslation('Por favor, ingrese su contraseña');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      print('Logging in with email: ${_emailController.text}');
                      bool success = await authService.login(
 _emailController.text,
 _passwordController.text,
                      );
                      if (success) {
                        print('Login successful!');
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
 );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(
 content: Text(languageProvider.getTranslation(
 'Correo electrónico o contraseña inválidos')),
 duration: const Duration(seconds: 3),
 ),
 );
                      }
                    } on Exception catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(languageProvider.getTranslation(
                              'Correo electrónico o contraseña inválidos')),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: Text(languageProvider.getTranslation('Login')),
 ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  languageProvider
                      .getTranslation('Don\'t have an account? Register here'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}