import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../color_constant/color_constant.dart';
import '../article page/article_page.dart';
import '../bottm nav bar/view.dart';

// WaveClipper for the top app bar
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 30);

    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) => false;
}

// News Service class
class NewsService {
  static const String apiUrl = 'https://newsapi.org/v2/everything';
  static const String apiKey = 'f0db19f0aa5e439c907f9731008261d2';

  // Fetch the medical news
  Future<List<Map<String, String>>> fetchMedicalNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$apiUrl?q=medicine+health+medical&from=2025-01-20&sortBy=publishedAt&apiKey=$apiKey',
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

        // Debugging the fetched data
        print('Fetched ${medicalArticles.length} medical articles');
        return medicalArticles;
      } else {
        print('Failed to load news: ${response.statusCode}');
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
      throw Exception('Error fetching news: $e');
    }
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;
  String _userName = ''; // Variable to store the fetched username
  List<Map<String, String>> newsArticles = [];
  bool isLoading = true;

  // Static data for Today's Medication and Upcoming Appointments
  final String medication = "No Medication to take today";
  final String appointmentTitle = "Biologic Infusion";
  final String appointmentTime = "09:00:00 - 13:00:00";
  final String appointmentDate = "15 February";
  final String appointmentDoctor = "Dr. Ramesh Hos";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    fetchNews();
  }

  Future<void> _fetchUserName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        // Fetch user data from Firestore
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['name'] ?? 'No name'; // Update username
          });
        } else {
          setState(() {
            _userName = 'No user data found';
          });
        }
      } catch (e) {
        // Log the error for debugging
        print('Error fetching user data: $e');
        setState(() {
          _userName = 'Error: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        _userName = 'User not authenticated';
      });
    }
  }

  // Fetch the medical news
  Future<void> fetchNews() async {
    try {
      final fetchedArticles = await NewsService().fetchMedicalNews();
      setState(() {
        newsArticles = fetchedArticles;
        isLoading = false;
      });

      // Debugging the fetched articles
      print('Fetched ${newsArticles.length} articles');
    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ClipPath with WaveClipper for the top bar
          ClipPath(
            clipper: WaveClipper(),
            child: Container(height: 160, color: AppColors.primary),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              leading: const Icon(Icons.home, color: Colors.white),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home Screen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Removed `const` to allow dynamic user name
                  Text(
                    'Welcome, $_userName', // Dynamically displaying username
                    style: TextStyle(
                      color: Color.fromARGB(255, 220, 220, 220),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    'Welcome to Grape!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Today's Medication Section
                  _buildMedicationSection(),

                  const SizedBox(height: 20),

                  // Upcoming Appointments Section
                  _buildUpcomingAppointmentsSection(),

                  const SizedBox(height: 20),

                  // Latest News Feed Section
                  _buildNewsFeedSection(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection() {
    return Center(
      child: Container(
        width:
            MediaQuery.of(context).size.width *
            0.9, // Increase width for better visibility
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(
                  Icons.medication,
                  color: AppColors.primary,
                ), // Medication Icon
                SizedBox(width: 10),
                Text(
                  "Today's Medication",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Medication Info Text
            Text(
              medication,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Add Medication Button (Center Aligned)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground, // Button color
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 50,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  // Add action to add medication
                },
                child: const Text(
                  "Add a medication",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildUpcomingAppointmentsSection() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Wider layout
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(
                  Icons.event_note,
                  color: AppColors.primary,
                ), // Calendar Icon
                SizedBox(width: 10),
                Text(
                  "Upcoming Appointments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Appointment Details in a Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE9F2FF), // Light blue background for the card
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Row
                  Row(
                    children: [
                      Text(
                        appointmentDate.split(" ")[0], // "15"
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointmentDate.split(" ")[1], // "February"
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            appointmentTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(), // Pushes the icon to the right
                      Icon(Icons.medical_services, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Time and Doctor Row
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appointmentTime,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        appointmentDoctor,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Centered "Add Appointment" Button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ), // Outline
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  // Add action to add an appointment
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Add new Appointment",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // Build the News Feed Section
  // Widget _buildNewsFeedSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "Latest from your news feed",
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 10),
  //       isLoading
  //           ? Center(child: CircularProgressIndicator())
  //           : ListView.builder(
  //             itemCount: newsArticles.length,
  //             shrinkWrap: true,
  //             physics: NeverScrollableScrollPhysics(),
  //             itemBuilder: (context, index) {
  //               final article = newsArticles[index];
  //               return _buildNewsCard(article);
  //             },
  //           ),
  //     ],
  //   );
  // }

  // News Feed Section
  Widget _buildNewsFeedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest from your news feed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Use ListView.builder to create news cards
        ListView.builder(
          itemCount: newsArticles.length,
          shrinkWrap: true, // Makes it scrollable inside the parent container
          physics:
              NeverScrollableScrollPhysics(), // Disable scrolling for this list
          itemBuilder: (context, index) {
            final article = newsArticles[index];
            return _buildNewsCard(
              article,
              context,
            ); // Pass both article and context
          },
        ),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, String> article, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the Article Detail Page and pass data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArticleDetailPage(
                  title: article['title']!,
                  description: article['description']!,
                  imageUrl: article['image']!,
                  author:
                      article['author'] ??
                      'Unknown', // Add a fallback for author
                  publishedAt: article['publishedAt']!,
                  content:
                      article['content'] ??
                      'No content available', // Fallback for content
                  url: article['url']!,
                ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 5,
        child: Row(
          children: [
            // Image section with fallback image handling
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  article['image'] != null && article['image']!.isNotEmpty
                      ? Image.network(
                        article['image']!,
                        width: 120,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://via.placeholder.com/150', // Default image if the URL fails to load
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.network(
                        'https://via.placeholder.com/150', // Default image when no URL provided
                        width: 120,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
            ),
            const SizedBox(width: 12),
            // Text section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      article['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      article['description']!,
                      style: const TextStyle(color: Colors.black54),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Published date
                    Text(
                      'Published on: ${article['publishedAt']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
