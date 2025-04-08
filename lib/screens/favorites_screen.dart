import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> favoriteQuotes = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuotes = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> removeFavorite(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuotes.removeAt(index);
      prefs.setStringList('favorites', favoriteQuotes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
      ),
      body: favoriteQuotes.isEmpty
          ? const Center(child: Text('No favorite quotes yet 😢'))
          : ListView.builder(
              itemCount: favoriteQuotes.length,
              itemBuilder: (context, index) {
                final quote = favoriteQuotes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(quote),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => removeFavorite(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
