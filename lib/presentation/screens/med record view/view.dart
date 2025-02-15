import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../color_constant/color_constant.dart';

class MedicalRecordViewPage extends StatefulWidget {
  @override
  _MedicalRecordViewPageState createState() => _MedicalRecordViewPageState();
}

class _MedicalRecordViewPageState extends State<MedicalRecordViewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
  }

  Future<String> _getImageUrl(String fileName) async {
    try {
      String filePath = 'uploads/$fileName'; // File path stored in Firebase
      print("Fetching image from: $filePath");
      String fileUrl =
          await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      return fileUrl;
    } catch (e) {
      print("Error fetching image URL: $e");
      return ''; // Return empty string if image URL is not found or an error occurs
    }
  }

  Future<void> _downloadImage(String url) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    // After ensuring permissions
    var permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      try {
        Dio dio = Dio();
        String savePath =
            '/storage/emulated/0/Download/photo.jpg'; // Example path for Android
        await dio.download(url, savePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded successfully!')),
        );
      } catch (e) {
        print("Error downloading image: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading image')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied. Cannot download file')),
      );
    }
  }

  // Method to open the bottom sheet for the selected record
  void _showRecordDetails(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Condition: ${data['condition'] ?? 'Not Provided'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Diagnosis Date: ${data['diagnosis_date'] ?? 'Not Provided'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Operations: ${data['operations'] ?? 'Not Provided'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Operation Date: ${data['operation_date'] ?? 'Not Provided'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  'Blood Test: ${data['blood_tests'] ?? 'Not Provided'}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                // Triggers - show only if true
                if (data['triggers'] != null)
                  ...data['triggers'].entries.map((entry) {
                    if (entry.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: True',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return Container(); // If false, don't show anything
                  }).toList(),
                SizedBox(height: 10),
                // Check if file_urls exist and load the image URL directly
                if (data['file_urls'] != null && data['file_urls'].isNotEmpty)
                  Image.network(
                    data['file_urls'][0], // Use the file URL directly from Firestore
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // If the image is loaded, show it
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.expectedTotalBytes! > 0
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : 0
                                    : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Error loading image'));
                    },
                  ),
                SizedBox(height: 20),
                // Add a download button below the image
                ElevatedButton(
                  onPressed: () {
                    if (data['file_urls'] != null &&
                        data['file_urls'].isNotEmpty) {
                      _downloadImage(
                        data['file_urls'][0],
                      ); // Download the image
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Change the button color
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Download Image', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Height of the AppBar
        child: AppBar(
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
                  "View Records",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonText,
                  ),
                ),
                Text(
                  "All your medical records in one place",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 8.0, // Adds shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          actions: [],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('health_records')
                .where('user_id', isEqualTo: _userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records found.'));
          }

          // Get all records data
          var records = snapshot.data!.docs;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var recordData = records[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    recordData['condition'] ?? 'No Condition Provided',
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Diagnosis Date: ${recordData['diagnosis_date'] ?? 'Not Provided'}',
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    _showRecordDetails(
                      recordData,
                    ); // Show the details in the bottom sheet
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
