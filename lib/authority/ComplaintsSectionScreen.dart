import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ComplaintsSectionScreen extends StatefulWidget {
  const ComplaintsSectionScreen({super.key});

  @override
  State<ComplaintsSectionScreen> createState() =>
      _ComplaintsSectionScreenState();
}

class _ComplaintsSectionScreenState extends State<ComplaintsSectionScreen> {
  final Map<DateTime, List<String>> _complaints = {
    DateTime.now(): [
      "Overflowing garbage bin at Sector 5",
      "Unattended road debris"
    ],
    DateTime.now().subtract(const Duration(days: 1)): [
      "Drain blockage near Market Area"
    ],
  };
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedComplaints = [];
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedComplaints = _complaints[_selectedDate] ?? [];
  }

  void _onDateSelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _selectedComplaints = _complaints[selectedDate] ?? [];
    });
  }

  Future<void> _resolveComplaint(String complaint) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Simulate marking complaint as resolved
      setState(() {
        _selectedComplaints.remove(complaint);
        _complaints[_selectedDate] = _selectedComplaints;
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Complaint Resolved"),
          content: const Text("The complaint has been marked as resolved."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaints Section"),
      ),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: _onDateSelected,
            eventLoader: (date) => _complaints[date] ?? [],
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Display Complaints for Selected Date
          Expanded(
            child: _selectedComplaints.isEmpty
                ? const Center(
                    child: Text(
                      "No complaints for the selected date.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _selectedComplaints[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(complaint),
                          trailing: ElevatedButton(
                            onPressed: () => _resolveComplaint(complaint),
                            child: const Text("Resolve"),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
