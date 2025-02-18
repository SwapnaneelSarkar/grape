import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'package:flutter/cupertino.dart';

class AppointmentPage extends StatefulWidget {
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final TextEditingController doctorOrClinicNameController =
      TextEditingController();
  final TextEditingController purposeOfVisitController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedTime = '08:00'; // Default appointment time
  bool isLoading = false; // Local loading state

  // Handle the appointment creation
  Future<void> _addAppointment() async {
    if (doctorOrClinicNameController.text.isNotEmpty &&
        purposeOfVisitController.text.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loading indicator
      });

      try {
        // Get the current authenticated user's UID
        String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

        // Split the selected time to get hour and minute
        List<String> timeParts = selectedTime.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = 0; // We can set it to 0 for simplicity

        // Combine the selected date with the selected time
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
          minute,
        );

        // Add the appointment to Firestore with userId
        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorOrClinicName': doctorOrClinicNameController.text,
          'purposeOfVisit': purposeOfVisitController.text,
          'location': locationController.text,
          'appointmentDateTime': Timestamp.fromDate(
            combinedDateTime,
          ), // Store as Timestamp
          'userId':
              userId, // Save the user's ID to associate the appointment with the user
        });

        // Successfully added the appointment
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment scheduled successfully!')),
        );

        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Function to display time picker
  void _selectTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Select Appointment Time'),
          message: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(initialItem: 8),
            onSelectedItemChanged: (index) {
              setState(() {
                selectedTime =
                    '${index + 6}:00'; // Selecting from 8 AM to 11 AM
              });
            },
            children: List.generate(10, (index) {
              return Center(child: Text('${index + 6}:00'));
            }),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: Text('Done'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Height of the AppBar
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
              'Schedule Appointment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White color for the title
              ),
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Doctor or Clinic Name
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: TextField(
                controller: doctorOrClinicNameController,
                decoration: InputDecoration(
                  labelText: 'Doctor or Clinic Name',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.local_hospital,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Purpose of Visit
            Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: TextField(
                controller: purposeOfVisitController,
                decoration: InputDecoration(
                  labelText: 'Purpose of Visit',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                ),
              ),
            ),

            // Location (optional for clinics)
            Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location (optional)',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                ),
              ),
            ),

            // Appointment Date Picker
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate)
                  setState(() {
                    selectedDate = pickedDate;
                  });
              },
              child: AbsorbPointer(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                    color: AppColors.cardBackground,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text:
                                selectedDate.toLocal().toString().split(' ')[0],
                          ),
                          decoration: InputDecoration(
                            labelText: 'Select Appointment Date',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Appointment Time Picker (using scroll picker)
            Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Text(selectedTime, style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),

            // Schedule Appointment Button
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading
                : ElevatedButton(
                  onPressed: _addAppointment,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.buttonText,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.buttonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0, // Removed elevation
                  ),
                  child: Text(
                    'Schedule Appointment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
