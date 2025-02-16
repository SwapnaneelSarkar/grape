import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../color_constant/color_constant.dart';
import '../bottm nav bar/view.dart';

class ViewRemindersPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ViewRemindersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          // AppBar code as before...
        ),
        body: const Center(child: Text("User not authenticated")),
      );
    }

    // Initialize the local notification plugin
    _initializeNotifications();

    return Scaffold(
      appBar: AppBar(
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
                "Set Reminders     ",
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
        elevation: 8.0, // Adds shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('meds_reminder')
                      .doc(userId)
                      .collection('reminders')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reminders set yet."));
                }

                final reminders = snapshot.data!.docs;

                // Check time for reminders
                _checkTimeForReminders(reminders);

                return ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final reminderId = reminder.id;
                    final medicineName = reminder['medicineName'] ?? 'Unknown';
                    final time = (reminder['time'] as Timestamp).toDate();
                    final formattedTime = _formatTime(time);

                    final isActive = reminder['is_active'] ?? true;
                    final frequency = reminder['frequency'] ?? 'Custom';

                    return Dismissible(
                      key: Key(reminderId),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        FirebaseFirestore.instance
                            .collection('meds_reminder')
                            .doc(userId)
                            .collection('reminders')
                            .doc(reminderId)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Reminder deleted")),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ),
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            medicineName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Time: $formattedTime",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                "Frequency: $frequency",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          trailing: Switch(
                            value: isActive,
                            onChanged: (bool value) {
                              FirebaseFirestore.instance
                                  .collection('meds_reminder')
                                  .doc(userId)
                                  .collection('reminders')
                                  .doc(reminderId)
                                  .update({'is_active': value});
                            },
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/reminder');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Initialize notifications
  void _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings = InitializationSettings(android: android);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Check if current time matches reminder time
  void _checkTimeForReminders(List<QueryDocumentSnapshot> reminders) async {
    final currentTime = DateTime.now();

    for (var reminder in reminders) {
      final time = (reminder['time'] as Timestamp).toDate();
      final reminderTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        time.hour,
        time.minute,
      );

      if (currentTime.isAtSameMomentAs(reminderTime)) {
        _showNotification(reminder['medicineName'], reminder['time']);
      }
    }
  }

  // Show notification with sound and vibration
  Future<void> _showNotification(String medicineName, Timestamp time) async {
    var androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Medicine Reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true, // Enable sound
      enableVibration: true, // Enable vibration
      vibrationPattern: Int64List.fromList([
        0,
        1000,
        500,
        1000,
      ]), // Custom vibration pattern
    );

    var platform = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Time for $medicineName!',
      'It\'s time to take your medicine.',
      platform,
      payload: 'item x',
    );
  }

  // Format time to display in 12-hour format
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }
}
