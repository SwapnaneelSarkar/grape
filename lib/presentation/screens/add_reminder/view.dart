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
  final TextEditingController _frequencyController =
      TextEditingController(); // Controller for frequency text field
  int _selectedHour = 8; // Default to 8 AM
  int _selectedMinute = 0; // Default to 00 minutes
  bool _isAm = true; // Track AM/PM
  List<bool> _daysSelected = List.generate(
    7,
    (index) => false,
  ); // Days of the week (Mon-Sun)
  String _frequency = 'Daily'; // Non-nullable String, default to 'Daily'

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
                  _buildTimePicker(12, (value) {
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
                  const SizedBox(width: 10),
                  // AM/PM toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAm = !_isAm;
                      });
                    },
                    child: Text(
                      _isAm ? 'AM' : 'PM',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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

  void _showFrequencyPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Set Frequency"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Daily radio button
                    RadioListTile<String>(
                      title: const Text("Daily"),
                      value: 'Daily',
                      groupValue: _frequency,
                      onChanged: (value) {
                        setState(() {
                          _frequency = value!;
                          _daysSelected = List.generate(
                            7,
                            (index) => true,
                          ); // Select all days for daily
                        });
                      },
                    ),
                    const Divider(),
                    // Individual days checkboxes
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: List.generate(7, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _daysSelected[index] =
                                  !_daysSelected[index]; // Toggle the selection

                              // If all days are selected, automatically select 'Daily'
                              if (_daysSelected.every((day) => day)) {
                                _frequency = 'Daily';
                              } else {
                                _frequency =
                                    _getSelectedDays(); // Store selected days
                              }
                            });
                          },
                          child: FilterChip(
                            label: Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][index],
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            selected: _daysSelected[index],
                            onSelected: (value) {
                              setState(() {
                                _daysSelected[index] = value;

                                // If all days are selected, automatically select 'Daily'
                                if (_daysSelected.every((day) => day)) {
                                  _frequency = 'Daily';
                                } else {
                                  _frequency =
                                      _getSelectedDays(); // Store selected days
                                }
                              });
                            },
                            selectedColor:
                                AppColors
                                    .primary, // Highlight selected with blue
                            backgroundColor: AppColors.cardBackground,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color:
                                    _daysSelected[index]
                                        ? AppColors.primary
                                        : Colors
                                            .transparent, // Blue border when selected
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to return selected days as an array
  String _getSelectedDays() {
    final selectedDays = <String>[];

    if (_daysSelected[0]) selectedDays.add('Mon');
    if (_daysSelected[1]) selectedDays.add('Tue');
    if (_daysSelected[2]) selectedDays.add('Wed');
    if (_daysSelected[3]) selectedDays.add('Thu');
    if (_daysSelected[4]) selectedDays.add('Fri');
    if (_daysSelected[5]) selectedDays.add('Sat');
    if (_daysSelected[6]) selectedDays.add('Sun');

    return selectedDays.join(
      ', ',
    ); // Return days as a comma-separated string (optional)
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineReminderBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
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
                                      "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}", // Show selected time
                                ),
                                decoration: InputDecoration(
                                  labelText: "Time",
                                  hintText:
                                      "${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')} ${_isAm ? 'AM' : 'PM'}",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _frequencyController,
                            decoration: InputDecoration(
                              labelText: "Frequency",
                              hintText: _frequency,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    _showFrequencyPopup, // Show frequency popup
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
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
                                            frequency:
                                                _frequency, // Include frequency
                                          ),
                                        );
                                      }
                                      : null,
                              child:
                                  state is MedicineReminderLoading
                                      ? const CircularProgressIndicator()
                                      : const Text("Set Reminder"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 25,
                                ),
                                textStyle: const TextStyle(fontSize: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
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
