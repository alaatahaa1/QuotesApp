import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load saved theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save theme preference to shared preferences
  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  // Toggle theme and save preference
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      _saveThemePreference(_isDarkMode);
    });
    // This triggers a theme change in the app
    if (_isDarkMode) {
      QuotesApp.of(context)?.setDarkMode();
    } else {
      QuotesApp.of(context)?.setLightMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),
            const SizedBox(height: 20),
            // Footer with developer and copyright info
            const Divider(),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Developed by Alaataha',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      // You can add functionality to open the website here
                      // For example, using URL launcher to open the website
                    },
                    child: const Text(
                      '© 2025 All Rights Reserved | alaataha.dev',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
