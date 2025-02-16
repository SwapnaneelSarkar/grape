import 'package:flutter/material.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String publishedAt;
  final String content;
  final String url;

  // Constructor to receive data
  ArticleDetailPage({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.content,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          // This centers the title
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center, // Aligns text vertically in the center
            crossAxisAlignment:
                CrossAxisAlignment
                    .center, // Ensures text is centered horizontally
            children: [
              Text(
                title, // Use the article's title here
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // Use white color for title text
                ),
              ),
            ],
          ),
        ),
        backgroundColor:
            AppColors.primary, // Replace with AppColors.primary if needed
        elevation: 8.0, // Adds shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image with a border and rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        'https://via.placeholder.com/150',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Published Date and Author
            Text(
              'By: $author | Published on: $publishedAt',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 20),

            // Article Content
            Text(content, style: TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),

            // Link to the original article with a styled button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Launch the URL of the article
                  launch(url);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Read Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
