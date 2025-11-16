
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String quoteText = "Loading...";
  String quoteAuthor = "—";
  String quoteTags = "";

  late final ApiService apiService;
  late final FlutterTts flutterTts;

  String selectedVoice = "female";

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    flutterTts = FlutterTts();
    _loadVoicePreference();
    getNewQuote();

    // optional: warm-up voices (non-blocking)
    flutterTts.getVoices.then((v) => debugPrint("Available voices: $v"));
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('voiceType');
    if (!mounted) return;
    setState(() {
      selectedVoice = v ?? "female";
    });
  }

  Future<void> getNewQuote() async {
    try {
      final response = await apiService.fetchRandomQuote();
      if (!mounted) return;
      setState(() {
        quoteText = response['text'] ?? "";
        quoteAuthor = response['author'] ?? "—";
        quoteTags = (response['tags'] as List? ?? []).join(", ");
      });
    } catch (e) {
      debugPrint("Error fetching quote: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to load new quote')));
    }
  }

  Future<void> addToFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteQuotes = prefs.getStringList('favorites') ?? <String>[];
    final quote = '"$quoteText" – $quoteAuthor';
    if (!favoriteQuotes.contains(quote)) {
      favoriteQuotes.add(quote);
      await prefs.setStringList('favorites', favoriteQuotes);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added to favorites ❤️')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('This quote is already in your favorites!')));
    }
  }

  void shareQuote() {
    Share.share('"$quoteText" – $quoteAuthor');
  }

  // ---------- TTS: American accent + safe handling ----------
 // ---------- TTS: American accent + safe handling ----------
void speakQuote() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String voicePref = prefs.getString('voiceType') ?? "female";

    await flutterTts.setLanguage('en-US'); // Force American
    await flutterTts.setSpeechRate(0.48);
    await flutterTts.setVolume(1.0);

    // Get voices
    List<dynamic> rawVoices = (await flutterTts.getVoices) ?? [];
    List<Map<String, dynamic>> voices = rawVoices
        .whereType<Map>()
        .map((v) => Map<String, dynamic>.from(v))
        .toList();

    // Filter **only American English voices**
    List<Map<String, dynamic>> usVoices = voices.where((v) {
      return v["locale"] != null &&
             v["locale"].toString().toLowerCase().startsWith("en-us");
    }).toList();

    Map<String, dynamic>? chosenVoice = {};

    // --- Try matching gender keywords ---
    if (voicePref == "female") {
      chosenVoice = usVoices.firstWhere(
        (v) => v["name"].toString().toLowerCase().contains("female") ||
               v["name"].toString().toLowerCase().contains("f") ||
               (v["gender"] == "female"),
        orElse: () => {},
      );
    } else {
      chosenVoice = usVoices.firstWhere(
        (v) => v["name"].toString().toLowerCase().contains("male") ||
               v["name"].toString().toLowerCase().contains("m") ||
               (v["gender"] == "male"),
        orElse: () => {},
      );
    }

    // If still none → fallback to any US voice
    if (chosenVoice.isEmpty && usVoices.isNotEmpty) {
      chosenVoice = usVoices.first;
    }

    // Apply chosen voice
    if (chosenVoice.isNotEmpty) {
      await flutterTts.setVoice({
        "name": chosenVoice["name"],
        "locale": chosenVoice["locale"],
      });
    }

    // --- Apply pitch to simulate gender (always works) ---
    if (voicePref == "male") {
      await flutterTts.setPitch(0.78); // Deeper American male
    } else {
      await flutterTts.setPitch(1.13); // Brighter American female
    }

    await flutterTts.speak('"$quoteText" — by $quoteAuthor');

  } catch (e) {
    print("TTS Error: $e");
  }
}



  // ---------- Styling helpers ----------
  Color _softTeal(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? const Color(0xFF0F4C49) // deep muted teal in dark
      : const Color(0xFF8FD4C6); // light soft teal in light

  Color _cardColor(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.black.withOpacity(0.45)
      : Colors.white.withOpacity(0.85);

  Color _textColor(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Colors.white70
      : Colors.grey[900]!;

  // action button builder with responsive minWidth
  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final buttonBg = dark ? Colors.white12 : Colors.white;
    final iconColor = dark ? Colors.white : _softTeal(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, minHeight: 44),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: dark ? Colors.white70 : Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard(BuildContext context, double maxWidth) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(dark ? 0.06 : 0.7)),
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quote text
            Text(
              '"$quoteText"',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 20,
                height: 1.4,
                fontStyle: FontStyle.italic,
                color: _textColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "- $quoteAuthor",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _textColor(context).withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (quoteTags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tags: $quoteTags",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textColor(context).withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    // calmer gradient choices
    final Gradient bgGradient = dark
        ? const LinearGradient(
            colors: [Color(0xFF071826), Color(0xFF052B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFE9F7F3), Color(0xFFD6F1EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      // let appbar sit on top but not behind system bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Quotes',
            style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700, color: dark ? Colors.white : _softTeal(context))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: dark ? Colors.white70 : _softTeal(context)),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: dark ? Colors.white70 : _softTeal(context)),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            // cap card width for large screens
            final double cardMaxWidth = constraints.maxWidth > 700 ? 700 : constraints.maxWidth - 40;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // spacing
                  const SizedBox(height: 8),

                  // glass card
                  _glassCard(context, cardMaxWidth),

                  const SizedBox(height: 28),

                  // Action buttons - responsive: use Wrap so buttons wrap without overflow
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _actionButton('New', Icons.refresh, getNewQuote),
                      _actionButton('Favorite', Icons.favorite_border, addToFavorites),
                      _actionButton('Share', Icons.share, shareQuote),
                      _actionButton('Read', Icons.volume_up, speakQuote),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // subtle footer
                  Opacity(
                    opacity: 0.7,
                    child: Text(
                      'Developed by Alaataha • © 2025',
                      style: GoogleFonts.inter(fontSize: 12, color: dark ? Colors.white60 : Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
