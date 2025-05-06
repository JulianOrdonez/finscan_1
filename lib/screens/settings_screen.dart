import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter_application_2/screens/support_screen.dart';
import 'package:flutter_application_2/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'MXN', 'COP'];

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  /// Load the selected currency from shared preferences.
  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? 'USD';
    });
  }

  /// Save the selected currency to shared preferences.
  Future<void> _saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                "Ajustes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSettingCard(
              title: 'Modo Oscuro',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            _buildSettingCard(
              title: 'Moneda',
              trailing: DropdownButton<String>(
                value: _selectedCurrency,
                items: _currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCurrency = newValue;
                    });
                    _saveSelectedCurrency(newValue);
                  }
                },
              ),
            ),
            _buildSettingCard(
                title: 'Cerrar Sesión',
                leading: Icon(Icons.logout),
                onTap: () => _logout(context)),
            _buildSettingCard(
              title: 'Soporte al Usuario',
              leading: Icon(Icons.support_agent),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    Widget? trailing,
    Icon? leading,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ListTile(
          leading: leading,
          title: Text(title),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}