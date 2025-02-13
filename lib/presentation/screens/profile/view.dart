import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../bottm nav bar/view.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(
      FetchProfile(),
    ); // Dispatch event to fetch profile data
  }

  // Navigate to another page on section tap
  void _navigateToSection(String section) {
    print('Navigating to $section');
  }

  // Log out user
  void _logout() {
    // Implement logout logic here
    // Example: FirebaseAuth.instance.signOut();
    print("Logging out...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                // Shimmer Effect for Profile Card and Sections
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shimmer for Heading
                      Center(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            width: 200,
                            height: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Shimmer for Profile Card
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 200,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 180,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 160,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 180,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Shimmer for Sections
                      const SizedBox(height: 20),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),
                      _buildShimmerTile(),

                      // Log out button at the bottom, centered
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20,
                            ),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ProfileLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Heading - centered and grey color
                      Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Change color to grey
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Card
                      Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white, // Remove shadow/elevation
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius:
                                    35, // Smaller radius for the profile icon
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50, // Smaller icon size
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Name: ${state.name}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Email: ${state.email}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Age: ${state.age}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Gender: ${state.gender}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Phone: ${state.phone}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sections below the profile card
                      const SizedBox(height: 20),
                      _buildSectionTile('My Appointments'),
                      _buildSectionTile('My Meds'),
                      _buildSectionTile('Health Records'),
                      _buildSectionTile('Edit Profile'),
                      _buildSectionTile('Feedback'),
                      _buildSectionTile('Terms and Conditions'),
                      _buildSectionTile('Privacy Policy'),

                      // Log out button at the bottom, centered
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20,
                            ),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ProfileFailure) {
                return Center(
                  child: Text(state.error, style: TextStyle(color: Colors.red)),
                );
              }
              return const Center(child: Text('Something went wrong.'));
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
      ), // Add the existing BottomNavBar
    );
  }

  // Shimmer helper function to build the section tiles
  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.arrow_forward_ios, color: Colors.blue),
              const SizedBox(width: 16),
              Container(width: 150, height: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build the section tiles
  Widget _buildSectionTile(String sectionName) {
    return GestureDetector(
      onTap: () => _navigateToSection(sectionName),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white, // Remove shadow/elevation
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.arrow_forward_ios, color: Colors.blue),
              const SizedBox(width: 16),
              Text(
                sectionName,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
