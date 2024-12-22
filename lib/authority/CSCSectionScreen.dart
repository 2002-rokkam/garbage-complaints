// authority/CSCSectionScreen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class CSCSectionScreen extends StatefulWidget {
  const CSCSectionScreen({super.key});

  @override
  _CSCSectionScreenState createState() => _CSCSectionScreenState();
}
class _CSCSectionScreenState extends State<CSCSectionScreen> {
  final List<File> _beforeImages = [];
  final List<File> _afterImages = [];
  final ImagePicker _picker = ImagePicker();

  DateTime selectedDate = DateTime.now();
  DateTime currentMonth =
      DateTime.now(); // Initially focused on the current month

  // Method to pick an image from the gallery or camera
  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      setState(() {
        if (type == "before") {
          _beforeImages.add(File(pickedFile.path));
        } else {
          _afterImages.add(File(pickedFile.path));
        }
      });
    }
  }

  // Method to display a dialog with an enlarged image
  void _viewImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(imageFile),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  // Get the list of 10 consecutive dates centered around the selected date
  List<DateTime> _getVisibleDates() {
    final today = selectedDate;
    final daysBefore = 2; // 5 days before
    final daysAfter = 40; // 4 days after

    List<DateTime> dates = [];

    // Add 5 days before the current date
    for (int i = daysBefore; i > 0; i--) {
      dates.add(today.subtract(Duration(days: i)));
    }

    // Add the selected date
    dates.add(today);

    // Add 4 days after the current date
    for (int i = 1; i <= daysAfter; i++) {
      dates.add(today.add(Duration(days: i)));
    }

    return dates;
  }

  // Method to pick a date using the DatePicker
  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        currentMonth =
            DateTime(pickedDate.year, pickedDate.month); // Update current month
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> visibleDates = _getVisibleDates(); // List of 10 dates

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("CSC Section"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scrollable Date Line for the Visible Dates (10 dates)
              Container(
                height: 80.0,
                child: Row(
                  children: [
                    // Month Label (Dec, Jan)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        DateFormat('MMM')
                            .format(selectedDate), // Short month name
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Dates Row
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: visibleDates.length,
                        itemBuilder: (context, index) {
                          DateTime date = visibleDates[index];
                          bool isToday = isSameDay(date, DateTime.now());
                          bool isSelected = isSameDay(date, selectedDate);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : (isToday ? Colors.yellow : Colors.red),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              width: 50,
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('E').format(date),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Before and After Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage("before"),
                    child: const Text("Upload Before"),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage("after"),
                    child: const Text("Upload After"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Display Before Images
              _buildImageList(_beforeImages, "Before Cleaning Images"),

              // Display After Images
              _buildImageList(_afterImages, "After Cleaning Images"),
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildImageList(List<File> images, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        images.isEmpty
            ? const Text("No images uploaded.")
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images
                    .map(
                      (image) => GestureDetector(
                        onTap: () => _viewImage(image),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 16),
      ],
    );
  }
}
