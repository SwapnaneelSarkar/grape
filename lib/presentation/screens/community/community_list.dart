import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grape/config/firebase_config.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'package:grape/presentation/screens/community/community_detail.dart';
import 'package:grape/presentation/screens/community/create_community.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import '../../../models/community.dart';
import '../bottm nav bar/view.dart';

class CommunityListPage extends StatefulWidget {
  @override
  _CommunityListPageState createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  bool _loading = true;
  List<Community> _communities = [];
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 1; // Set the default tab to 'Community' (index 1)

  @override
  void initState() {
    super.initState();
    _fetchCommunities();

    // Add a listener for scroll notifications to trigger reload
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == 0) {
        _fetchCommunities(); // Reload data when the user scrolls to the top
      }
    });
  }

  Future<void> _fetchCommunities() async {
    setState(() {
      _loading = true;
    });

    try {
      final snapshot = await firestore.collection('communities').get();
      setState(() {
        _communities =
            snapshot.docs.map((doc) {
              final community = Community.fromFirestore(doc);
              return community;
            }).toList();
      });
    } catch (e) {
      print("Error fetching communities: $e");
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Communities     ",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
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
        actions: [],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification &&
              scrollNotification.metrics.pixels == 0) {
            // If scrolled to the top, trigger reload
            _fetchCommunities();
            return true;
          }
          return false;
        },
        child:
            _loading
                ? _buildShimmerEffect() // Show shimmer effect when loading
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _communities.length,
                  itemBuilder: (context, index) {
                    final community = _communities[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                community.profileImageUrl.isEmpty
                                    ? AssetImage('assets/community.png')
                                    : NetworkImage(community.profileImageUrl),
                            child:
                                community.profileImageUrl.isEmpty
                                    ? CircularProgressIndicator()
                                    : null,
                          ),
                          title: Text(
                            community.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(community.description),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CommunityDetailPage(
                                      community: community,
                                    ),
                              ),
                            );
                          },
                        ),
                        Divider(color: Colors.grey[300], thickness: 1),
                      ],
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCommunityPage()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Create a Community',
        backgroundColor: AppColors.buttonBackground,
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

  // Method to build the shimmer effect while data is loading
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(15),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                ),
                title: Container(
                  color: Colors.grey[300],
                  height: 20,
                  width: 150,
                ),
                subtitle: Container(
                  color: Colors.grey[300],
                  height: 15,
                  width: 100,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
