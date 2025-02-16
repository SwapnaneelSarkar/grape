import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../color_constant/color_constant.dart';
import 'bloc.dart'; // Import your Bloc
import 'event.dart'; // Import your Event
import 'state.dart'; // Import your State

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(body: Center(child: Text("User not authenticated")));
    }

    return Scaffold(
      appBar: AppBar(
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
                "Edit profile     ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonText,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [],
      ),
      body: BlocProvider(
        create: (_) => EditProfileBloc(),
        child: BlocListener<EditProfileBloc, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully')),
              );
            }
            if (state is EditProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating profile: ${state.error}'),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("No user data found"));
                }

                final userData = snapshot.data!;
                final nameController = TextEditingController(
                  text: userData['name'],
                );
                final emailController = TextEditingController(
                  text: userData['email'],
                );
                final phoneController = TextEditingController(
                  text: userData['phone'],
                );
                final dobController = TextEditingController(
                  text: userData['dob'],
                );
                final usernameController = TextEditingController(
                  text: userData['username'],
                );

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextField(
                        nameController,
                        'Name',
                        TextInputType.text,
                        Icons.person,
                      ),
                      _buildTextField(
                        emailController,
                        'Email',
                        TextInputType.emailAddress,
                        Icons.email,
                      ),
                      _buildTextField(
                        phoneController,
                        'Phone',
                        TextInputType.phone,
                        Icons.phone,
                      ),
                      _buildTextField(
                        dobController,
                        'Date of Birth',
                        TextInputType.datetime,
                        Icons.calendar_today,
                      ),
                      _buildTextField(
                        usernameController,
                        'Username',
                        TextInputType.text,
                        Icons.account_circle,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<EditProfileBloc>().add(
                            UpdateProfileSubmitted(
                              name: nameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              dob: dobController.text,
                              username: usernameController.text,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 35,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.buttonBackground,
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        child: Text(
                          "Update Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.primary),
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
