import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/auth_service.dart';
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

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCurrency = prefs.getString('currency') ?? 'USD';
  }

  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);    
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Modo Oscuro',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Moneda',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      items: _currencies.map((String currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCurrency = newValue!;
                          final prefs = SharedPreferences.getInstance();
                          prefs.then((value) => value.setString('currency', newValue));
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () {
                    AuthService().logout().then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    ));
                   
                 },
                
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Soporte al Usuario'),
                onTap: () {
                  // Implement support logic here
                  // ignore: avoid_print
                  print('Soporte al Usuario');
                },
              ),
            ),
             const SizedBox(height: 20),
            const Center(
              child: Text(
                'FinScan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}