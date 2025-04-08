import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(QuotesApp());
}

class QuotesApp extends StatefulWidget {
  @override
  _QuotesAppState createState() => _QuotesAppState();

  static _QuotesAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_QuotesAppState>();
}

class _QuotesAppState extends State<QuotesApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Toggle dark mode
  void setDarkMode() {
    setState(() {
      _isDarkMode = true;
    });
    _saveThemePreference();  // Save the preference after change
  }

  // Toggle light mode
  void setLightMode() {
    setState(() {
      _isDarkMode = false;
    });
    _saveThemePreference();  // Save the preference after change
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quotes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.deepPurple, // This is the primary color for the app
        fontFamily: 'Georgia',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple, // Use the same color for dark theme
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/favorites': (context) => FavoritesScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
