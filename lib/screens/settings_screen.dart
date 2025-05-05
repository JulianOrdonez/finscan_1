import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';
import '../theme_provider.dart';

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
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Ajustes",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                child:  Text(currency),
              );
            }).toList(),
            onChanged: (String? newValue) {
              
                _selectedCurrency = newValue!;
                final prefs = SharedPreferences.getInstance();
                prefs.then((value) => value.setString('currency', newValue));
              
            },
        ),
        _buildSettingCard(
            title: 'Cerrar Sesión',
            leading: Icon(Icons.logout),
            onTap: () {
              AuthService().logout().then((value) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ));
            },
          ),
                _buildSettingCard(
          title: 'Soporte al Usuario',
          leading: Icon(Icons.support_agent),
          onTap: () {
            print('Soporte al Usuario');
          },
        ),
      ],
    );
  }

  Widget _buildSettingCard({required String title, Widget? trailing, Icon? leading, VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: leading,
        title: Text(title),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
