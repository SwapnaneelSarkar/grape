import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';

class FirebaseUploader extends StatefulWidget {
  @override
  _FirebaseUploaderState createState() => _FirebaseUploaderState();
}

class _FirebaseUploaderState extends State<FirebaseUploader> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Disease restrictions (example)
  Map<String, List<String>> diseaseRestrictions = {
    "diabetes": ["sugar", "white bread", "potato", "high fructose corn syrup"],
    "asthma": ["peanuts", "dairy", "eggs", "wheat"],
    "cancer": ["processed meats", "alcohol", "sugar", "high-fat foods"],
  };

  // Function to read the CSV and upload to Firebase
  Future<void> uploadDataToFirebase() async {
    final csvString = await rootBundle.loadString(
      'assets/Food Ingredients and Recipe Dataset with Image Name Mapping.csv',
    );
    List<List<dynamic>> csvData = CsvToListConverter().convert(csvString);

    // Iterate through each row (recipe) and upload to Firestore and Storage
    for (int i = 1; i < csvData.length; i++) {
      String title = csvData[i][1]; // Recipe title
      String imageName = csvData[i][4]; // Image name
      String cleanedIngredients = csvData[i][5]; // Cleaned ingredients
      String instructions = csvData[i][3]; // Instructions

      // Upload image to Firebase Storage
      await uploadImageToStorage(imageName);

      // Create recipe document in Firestore
      await firestore.collection('recipes').add({
        'title': title,
        'image_name': imageName,
        'ingredients': cleanedIngredients,
        'instructions': instructions,
        'image_url':
            'https://firebase_storage_url/${imageName}.jpg', // Store URL of the image
      });
    }
  }

  // Function to upload the image to Firebase Storage
  Future<void> uploadImageToStorage(String imageName) async {
    try {
      // Assuming you have the image as an asset
      final byteData = await rootBundle.load('assets/images/$imageName.jpg');
      final fileData = byteData.buffer.asUint8List();

      // Upload the image to Firebase Storage
      await storage.ref('recipe_images/$imageName.jpg').putData(fileData);

      print('Image $imageName uploaded successfully!');
    } catch (e) {
      print("Failed to upload image: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    uploadDataToFirebase(); // Trigger the upload process on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Recipes to Firebase')),
      body: Center(child: Text('Uploading data to Firebase...')),
    );
  }
}
