import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

import '../../../models/community.dart';
import '../../../config/firebase_config.dart';
import '../../../presentation/color_constant/color_constant.dart'; // Import AppColors for styling

class CreateCommunityPage extends StatefulWidget {
  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;
  XFile? _imageFile; // Store the image file

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  // Function to upload the image to Firebase Storage
  Future<String> _uploadImage() async {
    if (_imageFile == null) {
      return ''; // No image selected, return empty string
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(
        'community_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await fileRef.putFile(File(_imageFile!.path));

      final imageUrl =
          await fileRef.getDownloadURL(); // Get the image URL after uploading
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Return empty string in case of an error
    }
  }

  // Function to create the community
  Future<void> _createCommunity() async {
    final user = auth.currentUser;
    if (user == null) {
      // User not authenticated
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Upload image to Firebase Storage and get the URL
      String imageUrl = await _uploadImage();

      // Create the community document
      final communityRef = firestore.collection('communities').doc();
      final community = Community(
        id: communityRef.id,
        name: _nameController.text,
        description: _descriptionController.text,
        createdBy: user.uid,
        members: [user.uid], // Add creator as the first member
        profileImageUrl: imageUrl, // Save the image URL
      );

      await communityRef.set(community.toMap());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Community created!')));
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating community: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

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
          child: Text(
            _nameController.text.isEmpty
                ? "Create Community"
                : _nameController.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white, // Custom button text color
            ),
          ),
        ),
        backgroundColor: AppColors.primary, // Custom background color
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrapping the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        _imageFile == null
                            ? null
                            : FileImage(
                              File(_imageFile!.path),
                            ), // Show the selected image
                    child:
                        _imageFile == null
                            ? Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ) // Show camera icon if no image selected
                            : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Community Name
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  color: AppColors.cardBackground,
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Community Name",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.group, color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Community Description
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  color: AppColors.cardBackground,
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Community Description",
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.description,
                      color: AppColors.primary,
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              SizedBox(height: 20),
              // Centered Create Community Button
              Center(
                child: ElevatedButton(
                  onPressed: _loading ? null : _createCommunity,
                  child:
                      _loading
                          ? CircularProgressIndicator()
                          : Text("Create Community"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.buttonText,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    backgroundColor: AppColors.buttonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
