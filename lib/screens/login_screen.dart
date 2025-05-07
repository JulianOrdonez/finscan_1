import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/register_screen.dart';
import 'package:flutter_application_2/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('Login')),
      ),
      body: Center( // You might want to add SingleChildScrollView here to prevent overflow on smaller screens or with longer translations
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email', // This can be translated if desired
                    border: OutlineInputBorder(
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.translate('Please enter your email');
                    }
                    if (!value.contains('@')) {
                      return languageProvider.translate('Please enter a valid email');
                    }
                    return null;
                  }, // TODO: Add email validation regex for more robust validation
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return languageProvider.translate('Please enter your password');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              final authService = Provider.of<AuthService>(context, listen: false);
                              bool loggedIn = await authService.login(
                                  _emailController.text,
                                  _passwordController.text);
                              if (loggedIn) {
                                Navigator.pushReplacementNamed(context, '/home',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(languageProvider.translate('Invalid email or password'))),
                                );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')), // Consider translating the error message if possible, or providing a more user-friendly message.
                              );
                            } finally{
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                        child: Text(languageProvider.translate('Login')),
                      ), // This text could also be translated to 'Iniciar Sesión'
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(languageProvider.translate("Don't have an account? Register here")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}