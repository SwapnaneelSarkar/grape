import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import '../../color_constant/color_constant.dart';

class HealthRecordPage extends StatefulWidget {
  @override
  _HealthRecordPageState createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _diagnosisDateController =
      TextEditingController();
  final TextEditingController _operationController = TextEditingController();
  final TextEditingController _operationDateController =
      TextEditingController();
  final TextEditingController _bloodTestController = TextEditingController();
  String? uploadedFileUrl;

  List<String> triggers = [
    "Alcohol use",
    "Dietary changes",
    "Menstruating",
    "Missing or changing medications",
    "Smoking",
    "Stress",
    "Other",
  ];
  Map<String, bool> selectedTriggers = {};

  @override
  void initState() {
    super.initState();
    for (var trigger in triggers) {
      selectedTriggers[trigger] = false;
    }
  }

  // Method to open the date picker
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
      print("Selected date: ${controller.text}");
    }
  }

  // Method to open the popup to select the blood test result image
  void _openBloodTestPopup() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        uploadedFileUrl = pickedFile.path;
      });
      print("Uploaded file path: $uploadedFileUrl");
      // You can upload the image to Firebase here if needed
    }
  }

  // Open the popup to add the condition
  void _openConditionPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          title: Text(
            "Enter Diagnosis",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: SingleChildScrollView(
            // Ensure content is scrollable if it's too long
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _conditionController,
                  decoration: InputDecoration(
                    labelText: "Condition",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _diagnosisDateController,
                  decoration: InputDecoration(
                    labelText: "Diagnosis Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await _selectDate(_diagnosisDateController);
                  },
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Button color
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // Rounded button corners
                    ),
                    elevation:
                        5, // Optional: Adding shadow effect to the button
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Open the popup to add operation
  void _openOperationPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Dark background for a sleek look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // Rounded corners for modern look
          ),
          title: Text(
            "Add Operation",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 1.5,
            ),
          ),
          content: SingleChildScrollView(
            // Ensure the content is scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _operationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Operation",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    hintText: "Enter operation details",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _operationDateController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Operation Date",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                    hintText: "Select date",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    await _selectDate(_operationDateController);
                  },
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Save", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded button
                    ),
                    elevation: 5, // Add a subtle shadow
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Open the popup to select triggers
  void _openTriggerPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Select Triggers", style: TextStyle(fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      triggers.map((trigger) {
                        return CheckboxListTile(
                          title: Text(trigger),
                          value: selectedTriggers[trigger],
                          onChanged: (bool? value) {
                            // Using setState to update the selection and rebuild the UI
                            setState(() {
                              selectedTriggers[trigger] = value!;
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Save"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Uploads the file to Firebase Storage and returns the URL
  Future<String?> _uploadFileToFirebase(String filePath) async {
    try {
      File file = File(filePath);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('uploads/$fileName.jpg')
          .putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  // Submits the health record to Firestore
  Future<void> _submitHealthRecord(Map<String, dynamic> recordData) async {
    try {
      // Add user_id to the record data
      String userId = FirebaseAuth.instance.currentUser!.uid;
      recordData['user_id'] = userId;

      // Add the health record to Firestore
      await FirebaseFirestore.instance
          .collection('health_records')
          .add(recordData);
      print("Record submitted successfully!");
    } catch (e) {
      print("Error submitting record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Medical Records",
                  style: TextStyle(
                    fontSize: 18,
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
          actions: [], // Removed back button
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('My Condition', _openConditionPopup),
            SizedBox(height: 16),
            _buildSection('My Operations', _openOperationPopup),
            SizedBox(height: 16),
            _buildSection('My Blood Test Results', _openBloodTestPopup),
            SizedBox(height: 16),
            _buildSection(
              'Triggers and Contributors to Flare',
              _openTriggerPopup,
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> recordData = {
                    'condition': _conditionController.text,
                    'diagnosis_date': _diagnosisDateController.text,
                    'operations': _operationController.text,
                    'operation_date': _operationDateController.text,
                    'blood_tests': _bloodTestController.text,
                    'triggers': selectedTriggers,
                    // If no image uploaded, file_urls will be an empty list
                    'file_urls':
                        uploadedFileUrl != null ? [uploadedFileUrl!] : [],
                  };

                  print("Record data to be submitted: $recordData");

                  try {
                    // Only upload the image if one has been selected
                    if (uploadedFileUrl != null &&
                        uploadedFileUrl!.isNotEmpty) {
                      // Upload the image to Firebase Storage and get the URL
                      String? imageUrl = await _uploadFileToFirebase(
                        uploadedFileUrl!,
                      );

                      // If an image URL is returned, add it to the record data
                      if (imageUrl != null) {
                        recordData['file_urls'] = [imageUrl];
                      }
                    }

                    // Submit the record data to Firestore
                    await _submitHealthRecord(recordData);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Record submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Pop the current screen to go back
                    Navigator.pop(context);
                  } catch (e) {
                    // Show error message if something goes wrong
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error submitting record: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build each section with an edit button
  Widget _buildSection(String title, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: onPressed,
                ),
              ],
            ),
            Divider(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
