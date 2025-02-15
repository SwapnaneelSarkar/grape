import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart'; // Import the shimmer package

import '../../../models/community.dart';
import '../../../presentation/color_constant/color_constant.dart'; // Import AppColors for styling

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  CommunityDetailPage({required this.community});

  @override
  _CommunityDetailPageState createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  final _messageController = TextEditingController();
  bool _loading = false;
  List<Message> _messages = [];
  Map<String, String> _userNames = {}; // Store user names based on their userId

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  // Fetch messages from the database
  Future<void> _fetchMessages() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('communities')
              .doc(widget.community.id)
              .collection('messages')
              .orderBy('timestamp')
              .get();

      setState(() {
        _messages =
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
      });

      // Fetch user names for each message sender
      _fetchUserNames();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  // Fetch user names based on user IDs
  Future<void> _fetchUserNames() async {
    final users = await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in users.docs) {
      final userId = userDoc.id;
      final userName = userDoc.data()['name'];
      setState(() {
        _userNames[userId] = userName ?? 'Unknown User';
      });
    }
  }

  // Send a new message
  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _loading = true;
    });

    try {
      final messageRef =
          FirebaseFirestore.instance
              .collection('communities')
              .doc(widget.community.id)
              .collection('messages')
              .doc();
      final message = Message(
        senderId: user.uid,
        message: _messageController.text,
        timestamp: Timestamp.now(),
      );
      await messageRef.set(message.toMap());

      _messageController.clear();
      _fetchMessages(); // Refresh message list
    } catch (e) {
      print("Error sending message: $e");
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
        title: Padding(
          padding: const EdgeInsets.only(left: 100.0),
          child: Text(
            widget.community.name,
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
        // Wrapping the body in SingleChildScrollView for scrollability
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Messages List
              Container(
                height:
                    MediaQuery.of(context).size.height -
                    200, // Adjust height for the message list
                child:
                    _loading
                        ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: ListView.builder(
                            itemCount:
                                10, // Simulating a loading state for 10 messages
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0, // No shadow for messages
                                  color: Colors.grey.shade200,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          height: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final userName =
                                _userNames[message.senderId] ??
                                'Unknown User'; // Get the user's name

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Align(
                                alignment:
                                    message.senderId ==
                                            FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0, // No shadow for messages
                                  color:
                                      message.senderId ==
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser
                                                  ?.uid
                                          ? AppColors.primary.withOpacity(
                                            0.1,
                                          ) // Sender's message
                                          : AppColors.cardBackground,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          message.senderId ==
                                                  FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          message.message,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
              SizedBox(height: 20),
              // Message Input
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                        color: AppColors.cardBackground,
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Type a message',
                          border: InputBorder.none,
                          hintText: "Write something...",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.primary),
                    onPressed: _loading ? null : _sendMessage,
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
