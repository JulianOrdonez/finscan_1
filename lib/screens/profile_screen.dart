import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
import '../models/user.dart';
import '../theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final userId = await authService.getCurrentUserId();
    if (userId != null) {
      final user = await dbHelper.getUser(userId);
      setState(() {
        _user = user;
        _nameController.text = user?.name ?? '';
        _emailController.text = user?.email ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
 if (_user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not loaded')),
 );
 return;
 }
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      final success = await dbHelper.updateUser(User(
        id: _user?.id ?? 0, // Use optional chaining and null coalescing
        name: _nameController.text,
 email: _emailController.text, // Email is a required field in User model
        password: _user!.password,
      ));
      if (success) {
        setState(() {
          _user!.name = _nameController.text;
          _user!.email = _emailController.text;
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating profile')),
        );
      }
    }
  }

  Future<void> _changeUserPassword() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      if (_user != null) {
      if (await authService.validatePassword(
 _user!.email, _passwordController.text)) { // Email is a required field, so it should not be null
        final success = await dbHelper.updateUser(User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          password: _newPasswordController.text,
        ));

        if (success) {
          setState(() {
            _user!.password = _newPasswordController.text;
            _changePassword = false;
          });
          _passwordController.clear();
          _newPasswordController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error updating password')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect current password')),
        );
      }

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing && !_changePassword)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 24),
                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('Save Profile'),
                      ),
                    if (_isEditing)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            if (_user != null) {
                              _nameController.text = _user!.name;
                              _emailController.text = _user!.email;
                            }
                          });
                        },
                        child: const Text("Cancel"),
                      ),
                    if (!_isEditing)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _changePassword = true;
                          });
                        },
                        child: const Text("Change Password"),
                      ),
                    if (_changePassword)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Current Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter current password'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'New Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter new password'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _changeUserPassword,
                            child: const Text("Change Password"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _changePassword = false;
                              });
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}