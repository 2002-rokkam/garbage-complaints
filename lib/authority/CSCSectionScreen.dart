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

  // Widget to display a list of images
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

  // Method to get all the days of the current month
  List<DateTime> _getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    List<DateTime> days = [];

    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }
    return days;
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
    List<DateTime> daysInCurrentMonth = _getDaysInMonth(currentMonth);

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
              // Scrollable Date Line for the Current Month
              Container(
                height: 80.0,
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: daysInCurrentMonth.length,
                        itemBuilder: (context, index) {
                          DateTime date = daysInCurrentMonth[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('d').format(date),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSameDay(date, selectedDate)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSameDay(date, selectedDate)
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('E').format(date),
                                    style: TextStyle(fontSize: 12),
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
}
