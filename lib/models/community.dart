import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> members;
  final String profileImageUrl; // Add profileImageUrl to the model

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.members,
    required this.profileImageUrl, // Add this to the constructor
  });

  // Update the fromFirestore factory to include profileImageUrl
  factory Community.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Community(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      createdBy: data['createdBy'],
      members: List<String>.from(data['members']),
      profileImageUrl:
          data['profileImageUrl'] ?? '', // Default to empty string if not found
    );
  }

  // Update the toMap method to include profileImageUrl
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'members': members,
      'profileImageUrl': profileImageUrl, // Add profileImageUrl to the map
    };
  }
}

class Message {
  final String senderId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      message: data['message'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'senderId': senderId, 'message': message, 'timestamp': timestamp};
  }
}
