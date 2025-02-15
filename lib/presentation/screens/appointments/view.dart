import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';

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
        // Add the appointment to Firestore
        await FirebaseFirestore.instance.collection('appointments').add({
          'doctorOrClinicName': doctorOrClinicNameController.text,
          'purposeOfVisit': purposeOfVisitController.text,
          'location': locationController.text,
          'appointmentDate': selectedDate,
          'appointmentTime': selectedTime,
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

            // Appointment Time Picker
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
                    child: DropdownButton<String>(
                      value: selectedTime,
                      items:
                          ['08:00', '09:00', '10:00', '11:00']
                              .map(
                                (value) => DropdownMenuItem(
                                  child: Text(value),
                                  value: value,
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedTime = newValue!;
                        });
                      },
                      isExpanded: true,
                      underline: Container(),
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
