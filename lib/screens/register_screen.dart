import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../language_provider.dart';
import 'home_page.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getTranslation('Register')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Name'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getTranslation('Please enter your name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Email'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getTranslation('Please enter your email');
                  }
                  if (!value.contains('@')) {
                    return languageProvider.getTranslation('Please enter a valid email');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Password'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getTranslation('Please enter a password');
                  }
                  if (value.length < 6) {
                    return languageProvider.getTranslation('Password must be at least 6 characters');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: languageProvider.getTranslation('Confirm Password'),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return languageProvider.getTranslation('Please confirm your password');
                  }
                  if (value != _passwordController.text) {
                    return languageProvider.getTranslation('Passwords do not match');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await authService.register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${languageProvider.getTranslation('Registration failed. Please try again.')} ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: Text(languageProvider.getTranslation('Register')),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(languageProvider.getTranslation('Already have an account? Login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}