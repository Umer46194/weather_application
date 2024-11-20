import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv for environment variables

class NewsScreen extends StatelessWidget {
  Future<List<dynamic>> fetchNews() async {
    // Retrieve the API key from the .env file
    final apiKey = dotenv.env['NEWS_API_KEY'];
    if (apiKey == null) {
      throw Exception("API key is missing. Make sure it's defined in the .env file.");
    }

    // Make the API call
    final response = await http.get(Uri.parse(
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey',
    ));

    if (response.statusCode == 200) {
      // Parse and return the list of articles
      return json.decode(response.body)['articles'];
    } else {
      throw Exception('Failed to load news: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(articles[index]['title'] ?? 'No title available'),
                  subtitle: Text(articles[index]['description'] ?? 'No description available'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
