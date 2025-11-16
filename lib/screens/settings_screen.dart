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

  // NEW: Voice selection
  String _selectedVoice = 'female'; // default

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load theme + voice preference
  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedVoice = prefs.getString('voiceType') ?? 'female';
    });
  }

  // Save theme
  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  // Save selected voice type
  Future<void> _saveVoicePreference(String voiceType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('voiceType', voiceType);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
      _saveThemePreference(value);
    });

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
            // DARK MODE
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),

            const SizedBox(height: 20),

            // 🔥 AI VOICE SELECTION
            const Text(
              "Voice Type (AI Voice)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedVoice,
              items: const [
                DropdownMenuItem(
                  value: "female",
                  child: Text("Female Voice"),
                ),
                DropdownMenuItem(
                  value: "male",
                  child: Text("Male Voice"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedVoice = value!;
                });
                _saveVoicePreference(value!);
              },
            ),

            const SizedBox(height: 40),

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
                  const Text(
                    '© 2025 All Rights Reserved | alaataha.dev',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
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
