import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String quoteText = "";
  String quoteAuthor = "";
  String quoteTags = "";

  late ApiService apiService;
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    flutterTts = FlutterTts();
    getNewQuote();
  }

  // Fetch a new quote from the API
  void getNewQuote() async {
    try {
      var response = await apiService.fetchRandomQuote();
      setState(() {
        quoteText = response['text'];
        quoteAuthor = response['author'];
        quoteTags = (response['tags'] as List).join(", ");
      });
    } catch (e) {
      print("Error fetching quote: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load new quote')),
      );
    }
  }

  // Save the quote to favorites
  void addToFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteQuotes = prefs.getStringList('favorites') ?? [];
    String quote = '"$quoteText" – $quoteAuthor';

    if (!favoriteQuotes.contains(quote)) {
      favoriteQuotes.add(quote);
      await prefs.setStringList('favorites', favoriteQuotes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites ❤️')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This quote is already in your favorites!')),
      );
    }
  }

  // Share the quote
  void shareQuote() {
    Share.share('"$quoteText" – $quoteAuthor');
  }

  // Read the quote aloud using TTS
  void speakQuote() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setPitch(1.0); // Set pitch to a neutral level
    await flutterTts.setSpeechRate(0.5); // Set speech rate slower for clarity
    await flutterTts.setVolume(1.0); // Full volume for better clarity

    var voices = await flutterTts.getVoices;
    print(voices); // Check available voices

    await flutterTts.speak('"$quoteText" by $quoteAuthor');
  }

  @override
  Widget build(BuildContext context) {
    // Check the current theme's brightness
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.teal.shade50, // Soft background color
      appBar: AppBar(
        title: const Text("Quotes App"),
        backgroundColor: isDarkMode ? Colors.black : Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isDarkMode ? Colors.black : Colors.white, // Card color changes with theme
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '"$quoteText"',
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode ? Colors.white : Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "- $quoteAuthor",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.teal.shade700,
                        ),
                      ),
                    ),
                    if (quoteTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          "Tags: $quoteTags",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDarkMode ? Colors.white54 : Colors.teal.shade500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                AnimatedButton(
                  label: "New Quote",
                  icon: Icons.refresh,
                  onPressed: getNewQuote,
                  backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.teal,
                ),
                AnimatedButton(
                  label: "Favorite",
                  icon: Icons.favorite_border,
                  onPressed: addToFavorites,
                  backgroundColor: isDarkMode ? Colors.grey[700]! : Colors.teal.shade700,
                ),
                AnimatedButton(
                  label: "Share",
                  icon: Icons.share,
                  onPressed: shareQuote,
                  backgroundColor: isDarkMode ? Colors.grey[600]! : Colors.teal.shade800,
                ),
                AnimatedButton(
                  label: "Read Aloud",
                  icon: Icons.volume_up,
                  onPressed: speakQuote,
                  backgroundColor: isDarkMode ? Colors.grey[500]! : Colors.teal.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  const AnimatedButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) {
        setState(() {
          _scale = 0.95; // Slightly shrink the button when pressed
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0; // Reset the button size when released
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0; // Reset on cancel
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: ElevatedButton.icon(
          icon: Icon(widget.icon),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
