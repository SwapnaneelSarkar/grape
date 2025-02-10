import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grape/presentation/color_constant/color_constant.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class MedicineReminderView extends StatefulWidget {
  const MedicineReminderView({Key? key}) : super(key: key);

  @override
  State<MedicineReminderView> createState() => _MedicineReminderViewState();
}

class _MedicineReminderViewState extends State<MedicineReminderView> {
  final TextEditingController _medicineController = TextEditingController();
  int _selectedHour = 8; // Default to 8 AM
  int _selectedMinute = 0; // Default to 00 minutes

  // This will store the timestamp of the selected time.
  DateTime get selectedTime =>
      DateTime(2025, 2, 10, _selectedHour, _selectedMinute);

  // Method to show the scrollable time picker
  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Select Time",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour Picker
                  _buildTimePicker(24, (value) {
                    setState(() {
                      _selectedHour = value;
                    });
                  }),
                  const Text(" : ", style: TextStyle(fontSize: 24)),
                  // Minute Picker
                  _buildTimePicker(60, (value) {
                    setState(() {
                      _selectedMinute = value;
                    });
                  }),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Update the TextField with selected time
                  setState(() {});
                },
                child: const Text("Select Time"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper function to build scrollable time picker for hours/minutes
  Widget _buildTimePicker(int maxValue, ValueChanged<int> onChanged) {
    return Container(
      height: 100,
      width: 60,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50.0,
        onSelectedItemChanged: (index) => onChanged(index),
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            maxValue,
            (index) => Center(child: Text(index.toString().padLeft(2, '0'))),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineReminderBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            // Wrap the content inside a scrollable widget
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Set a Medicine Reminder",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocConsumer<MedicineReminderBloc, MedicineReminderState>(
                    listener: (context, state) {
                      if (state is MedicineReminderSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reminder Set Successfully!'),
                          ),
                        );
                      } else if (state is MedicineReminderFailure) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error)));
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        children: [
                          TextField(
                            controller: _medicineController,
                            decoration: InputDecoration(
                              labelText: "Medicine Name",
                              hintText: "Enter the medicine name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showTimePicker, // Open time picker
                            child: AbsorbPointer(
                              child: TextField(
                                controller: TextEditingController(
                                  text:
                                      "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}", // Show selected time
                                ),
                                decoration: InputDecoration(
                                  labelText: "Time",
                                  hintText:
                                      "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                state is! MedicineReminderLoading
                                    ? () {
                                      final medicineName =
                                          _medicineController.text.trim();
                                      final timeInUtc =
                                          selectedTime
                                              .toUtc(); // Convert to UTC DateTime

                                      context.read<MedicineReminderBloc>().add(
                                        MedicineReminderAdded(
                                          medicineName: medicineName,
                                          time:
                                              timeInUtc, // Store the UTC DateTime
                                        ),
                                      );
                                    }
                                    : null,
                            child:
                                state is MedicineReminderLoading
                                    ? const CircularProgressIndicator()
                                    : const Text("Set Reminder"),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
