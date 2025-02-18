import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';

class AppointmentShowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: true, // Ensures the back button is visible
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios, // iOS-style back arrow
              color: Colors.white, // White color for the back button
            ),
            onPressed: () => Navigator.pop(context), // Pop the current screen
          ),
          title: Center(
            child: Text(
              'View Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White color for the title
              ),
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0.0, // Remove elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('appointments')
                  .where(
                    'userId',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                  )
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final appointments = snapshot.data?.docs ?? [];

            if (appointments.isEmpty) {
              return Center(child: Text('No appointments found.'));
            }

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                var appointment = appointments[index];

                // Fetch and convert appointment date and time from Timestamp
                DateTime appointmentDateTime =
                    (appointment['appointmentDateTime'] as Timestamp).toDate();

                // Format the appointment date and time for display
                String formattedDate =
                    "${appointmentDateTime.toLocal().toString().split(' ')[0]} at ${appointmentDateTime.hour}:${appointmentDateTime.minute.toString().padLeft(2, '0')}";

                return Card(
                  margin: EdgeInsets.only(bottom: 12.0),
                  color: AppColors.cardBackground, // No shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      appointment['purposeOfVisit'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor/Clinic: ${appointment['doctorOrClinicName']}',
                        ),
                        SizedBox(height: 4),
                        Text('Location: ${appointment['location']}'),
                        SizedBox(height: 4),
                        Text('Date: $formattedDate'),
                      ],
                    ),
                    leading: Icon(
                      Icons.local_hospital,
                      color: AppColors.primary,
                    ),
                    // onTap: () {
                    //   // Add any action you want to perform when an appointment is tapped
                    // },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Add Appointment page
          Navigator.pushNamed(context, '/appointmentAdd');
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
