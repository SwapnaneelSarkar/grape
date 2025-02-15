import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// News API Service
class NewsService {
  static const String apiUrl = 'https://newsapi.org/v2/everything';
  static const String apiKey = 'f0db19f0aa5e439c907f9731008261d2';

  // Fetch the medical news
  Future<List<Map<String, String>>> fetchMedicalNews() async {
    final response = await http.get(
      Uri.parse(
        '$apiUrl?q=medicine+health+medical&from=2025-01-14&sortBy=publishedAt&apiKey=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      List<Map<String, String>> medicalArticles = [];
      final data = json.decode(response.body);

      for (var article in data['articles']) {
        medicalArticles.add({
          'title': article['title'],
          'description': article['description'],
          'image': article['urlToImage'] ?? '',
          'url': article['url'],
          'publishedAt': article['publishedAt'],
        });
      }
      return medicalArticles;
    } else {
      throw Exception('Failed to load news');
    }
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> newsArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  // Fetch the filtered medical news
  Future<void> fetchNews() async {
    try {
      final fetchedArticles = await NewsService().fetchMedicalNews();
      setState(() {
        newsArticles = fetchedArticles;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Build the News Feed Section
  Widget _buildNewsFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest from your news feed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          itemCount: newsArticles.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final article = newsArticles[index];
            return _buildNewsCard(article);
          },
        ),
      ],
    );
  }

  // News Article Card
  Widget _buildNewsCard(Map<String, String> article) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                article['image'] != null
                    ? Image.network(
                      article['image']!,
                      width: 120,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                    : const SizedBox(
                      width: 120,
                      height: 80,
                    ), // Default when no image
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  article['description']!,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  'Published on: ${article['publishedAt']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.blue,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading
              : _buildNewsFeedSection(), // Display the filtered medical news
    );
  }
}
