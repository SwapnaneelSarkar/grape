import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'bloc.dart';

class MedicationPage extends StatefulWidget {
  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final TextEditingController medicationNameController =
      TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  String frequency = '1';
  String reminderTime = '08:00';
  bool repeatDaily = true;

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
              'Add Medication',
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
            // Start Date Field
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedStartDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedStartDate)
                  setState(() {
                    selectedStartDate = pickedDate;
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
                                selectedStartDate.toLocal().toString().split(
                                  ' ',
                                )[0],
                          ),
                          decoration: InputDecoration(
                            labelText: 'Start date of medication',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Medication Name
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: TextField(
                controller: medicationNameController,
                decoration: InputDecoration(
                  labelText: 'Name of Medication',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.medical_services,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Dosage
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: TextField(
                controller: dosageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Dosage (mcg)',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.local_hospital,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            // Grouped Frequency, Repeat, and Time Fields
            Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.only(top: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                color: AppColors.cardBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dosage frequency
                  Row(
                    children: [
                      Icon(Icons.timelapse, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: frequency,
                          items:
                              ['1', '2', '3', '4', '5']
                                  .map(
                                    (value) => DropdownMenuItem(
                                      child: Text('$value Times a day'),
                                      value: value,
                                    ),
                                  )
                                  .toList(),
                          onChanged: (newValue) {
                            setState(() {
                              frequency = newValue!;
                            });
                          },
                          isExpanded: true,
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),

                  // Repeat daily toggle
                  Row(
                    children: [
                      Icon(Icons.repeat, color: AppColors.primary),
                      SizedBox(width: 12),
                      Text(
                        'Repeat Daily',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      Switch(
                        value: repeatDaily,
                        onChanged: (newValue) {
                          setState(() {
                            repeatDaily = newValue;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),

                  // Reminder time
                  Row(
                    children: [
                      Icon(Icons.alarm, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: reminderTime,
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
                              reminderTime = newValue!;
                            });
                          },
                          isExpanded: true,
                          underline: Container(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add Medication Button
            SizedBox(height: 20),
            BlocConsumer<MedicationBloc, MedicationState>(
              listener: (context, state) {
                if (state is MedicationAddedState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Medication added successfully!')),
                  );
                  Navigator.pop(context); // Go back to the previous screen
                } else if (state is MedicationErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.error}')),
                  );
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (medicationNameController.text.isNotEmpty &&
                        dosageController.text.isNotEmpty) {
                      context.read<MedicationBloc>().add(
                        AddMedicationEvent(
                          medicationName: medicationNameController.text,
                          dosage: int.parse(dosageController.text),
                          frequency: frequency,
                          reminderTime: reminderTime,
                          repeatDaily: repeatDaily,
                          startDate: selectedStartDate,
                        ),
                      );
                    }
                  },
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
                    'Add Medication',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
