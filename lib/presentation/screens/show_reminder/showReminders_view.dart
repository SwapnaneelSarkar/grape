import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../color_constant/color_constant.dart';

class ViewRemindersPage extends StatelessWidget {
  const ViewRemindersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reminders")),
        body: const Center(child: Text("User not authenticated")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reminders"),
        backgroundColor: AppColors.primary, // Color from the color constants
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          // Start a background task to check the time
          _checkTimeForReminders(reminders);

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final reminderId = reminder.id;
              final medicineName = reminder['medicineName'] ?? 'Unknown';
              final time =
                  (reminder['time'] as Timestamp)
                      .toDate(); // Assuming 'time' is a Timestamp

              // Format time with AM/PM
              final formattedTime = _formatTime(time);

              final isActive =
                  reminder['is_active'] ??
                  true; // Default to true if 'is_active' is missing
              final frequency =
                  reminder['frequency'] ??
                  'Custom'; // Get frequency (Daily or Custom)

              return Dismissible(
                key: Key(reminderId),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Delete reminder on swipe
                  FirebaseFirestore.instance
                      .collection('meds_reminder')
                      .doc(userId)
                      .collection('reminders')
                      .doc(reminderId)
                      .delete();
                  // Show snackbar message after deletion
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Reminder deleted")));
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
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
                          "Frequency: $frequency", // Display frequency
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
                        // Toggle the reminder's active status
                        FirebaseFirestore.instance
                            .collection('meds_reminder')
                            .doc(userId)
                            .collection('reminders')
                            .doc(reminderId)
                            .update({'is_active': value});
                      },
                      activeColor:
                          AppColors.primary, // Use color from the constants
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/reminder',
          ); // Navigate to Add Reminder page
        },
        backgroundColor: AppColors.primary, // Use color from the constants
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Method to check time for reminders
  void _checkTimeForReminders(List<QueryDocumentSnapshot> reminders) async {
    final currentTime = DateTime.now();

    // Loop through all reminders and check if any reminder's time matches the current time
    for (var reminder in reminders) {
      final time = (reminder['time'] as Timestamp).toDate();
      final reminderTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        time.hour,
        time.minute,
      );

      // If the reminder time matches the current time, show a notification
      if (currentTime.isAtSameMomentAs(reminderTime)) {
        _showNotification(reminder['medicineName'], reminder['time']);
      }
    }
  }

  // Method to show a local notification
  Future<void> _showNotification(String medicineName, Timestamp time) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const android = AndroidNotificationDetails(
      'reminder_channel',
      'Medicine Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platform = NotificationDetails(android: android);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Time for $medicineName!',
      'It\'s time to take your medicine.',
      platform,
      payload: 'item x',
    );
  }

  // Method to format the time with AM/PM
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
  }
}
