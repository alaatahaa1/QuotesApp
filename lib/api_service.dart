import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // API URL for fetching a random quote
  final String apiUrl = 'https://thequoteshub.com/api/random-quote';

  // Fetch a random quote
  Future<Map<String, dynamic>> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      throw Exception('Failed to load quote: $e');
    }
  }
}

