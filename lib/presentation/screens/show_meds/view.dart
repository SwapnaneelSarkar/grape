import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineShowPage extends StatelessWidget {
  const MedicineShowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Show Medications")),
      body: Column(
        children: [
          // Today section - show today's medications
          Expanded(child: MedicationSection(status: "today")),
          Divider(),

          // Ongoing section - show ongoing medications
          Expanded(child: MedicationSection(status: "ongoing")),
          Divider(),

          // Stopped section - show stopped medications
          Expanded(child: MedicationSection(status: "stopped")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the existing Add Medicine page
          Navigator.pushNamed(context, '/meds');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class MedicationSection extends StatelessWidget {
  final String status;

  const MedicationSection({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current authenticated user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User is not authenticated"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection(
                'users',
              ) // Use users collection for user-specific data
              .doc(user.uid) // Filter by the current user's UID
              .collection('medications')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Fetch the medications and debug print the values
        final medications = snapshot.data?.docs ?? [];
        print("Fetched ${medications.length} medications");

        return ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            var medication = medications[index];
            bool isOngoing =
                medication['ongoing'] ??
                false; // Fallback to false if 'ongoing' doesn't exist
            DateTime reminderTime =
                (medication['reminderTime'] as Timestamp).toDate();
            DateTime now = DateTime.now();

            // Logic to determine which section the medication should go to
            if (status == 'today') {
              // Show if the medication is ongoing and the time hasn't passed
              if (isOngoing && reminderTime.isAfter(now)) {
                return _buildMedicationTile(medication);
              }
            } else if (status == 'ongoing') {
              // Show ongoing if the medication's reminder time has passed
              if (isOngoing && reminderTime.isBefore(now)) {
                return _buildMedicationTile(medication);
              }
            } else if (status == 'stopped') {
              // Show if the medication is marked as stopped
              if (!isOngoing) {
                return _buildMedicationTile(medication);
              }
            }

            return SizedBox.shrink(); // Return an empty widget if it doesn't match the condition
          },
        );
      },
    );
  }

  Widget _buildMedicationTile(DocumentSnapshot medication) {
    return ListTile(
      title: Text(medication['medicationName']),
      subtitle: Text('Dosage: ${medication['dosage']}'),
      onTap: () {
        // Add any action you want to perform when a medication is tapped
      },
    );
  }
}
