// authority/workerComplaintsScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class workerComplaintsScreen extends StatefulWidget {
  @override
  _workerComplaintsScreenState createState() => _workerComplaintsScreenState();
}

class _workerComplaintsScreenState extends State<workerComplaintsScreen> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, int> complaintCounts = {};
  List<dynamic> complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaintData();
  }

  Future<void> _fetchComplaintData() async {
    final url =
        'https://8250-122-172-86-111.ngrok-free.app/api/complaints-by-gram-panchayat?gram_panchayat=Srinagar';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final complaintsList = data['complaints'];

        Map<DateTime, int> counts = {};
        for (var complaint in complaintsList) {
          final date = DateTime.parse(complaint['created_at']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          complaints = complaintsList;
          complaintCounts = counts;
        });
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintsListScreen(
          date: selectedDay,
          complaints: complaints,
          onUpdate: _fetchComplaintData, // Pass the refresh method
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints Calendar'),
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDateSelected,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final count = complaintCounts[date] ?? 0;
                if (count > 0) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintsListScreen extends StatelessWidget {
  final DateTime date;
  final List<dynamic> complaints;
  final VoidCallback onUpdate; // Callback to refresh data

  ComplaintsListScreen(
      {required this.date, required this.complaints, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final selectedDateComplaints = complaints.where((complaint) {
      final complaintDate = DateTime.parse(complaint['created_at']).toLocal();
      return complaintDate.year == date.year &&
          complaintDate.month == date.month &&
          complaintDate.day == date.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints on ${date.toLocal()}'.split(' ')[0]),
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: selectedDateComplaints.isEmpty
          ? Center(
              child: Text('No complaints found for this date.'),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: selectedDateComplaints.length,
              itemBuilder: (context, index) {
                final complaint = selectedDateComplaints[index];
                return ComplaintCard(
                  complaint: complaint,
                  onUpdate: onUpdate, // Pass the callback
                );
              },
            ),
    );
  }
}


class ComplaintCard extends StatefulWidget {
  final dynamic complaint;
  final VoidCallback onUpdate; // Callback for refreshing data

  ComplaintCard({required this.complaint, required this.onUpdate});

  @override
  _ComplaintCardState createState() => _ComplaintCardState();
}


class _ComplaintCardState extends State<ComplaintCard> {
  String _address = "Fetching address...";
  File? _imageFile;
  double? _latitude;
  double? _longitude;
late int workerId;
  String _workerEmail = '';
  
  @override
  void initState() {
    super.initState();
    _fetchAddress();
    _loadWorkerDetails();
  }

  Future<void> _fetchAddress() async {
    try {
      final photos = widget.complaint['photos'];
      if (photos.isNotEmpty) {
        final firstPhoto = photos[0];
        final latitude = firstPhoto['latitude'];
        final longitude = firstPhoto['longitude'];

        if (latitude != null && longitude != null) {
          List<Placemark> placemarks =
              await placemarkFromCoordinates(latitude, longitude);
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            String address =
                '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
            setState(() {
              _address = address;
            });
          } else {
            setState(() {
              _address = "No address found";
            });
          }
        }
      } else {
        setState(() {
          _address = "No coordinates available";
        });
      }
    } catch (e) {
      setState(() {
        _address = "Error: ${e.toString()}";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _getLocation();
      _showImagePopup();
    }
  }

  Future<void> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  void _showImagePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _submitFormData(); // Submit the image
                    },
                    child: Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {
                        _imageFile = null; // Clear the image
                      });
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
    return workerId;
  }

  Future<void> _loadWorkerDetails() async {
    workerId = await getWorkerId();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _workerEmail = prefs.getString('email') ?? '';
    });
  }

  Future<void> _submitFormData() async {
    if (_imageFile == null || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select an image and allow location access'),
      ));
      return;
    }

    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      'solved_compliant': await MultipartFile.fromFile(
        _imageFile!.path,
        filename: 'solved_complaint_image.jpg',
      ),
      'solved_lat': _latitude,
      'solved_long': _longitude,
      'worker_id': workerId,
      'worker_email': _workerEmail,
    });

    try {
      Response response = await dio.post(
        'https://8250-122-172-86-111.ngrok-free.app/api/update-complaint/${widget.complaint['complaint_id']}',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Complaint updated successfully'),
        ));
        widget.onUpdate(); 
        Navigator.pop(context,true);// Notify parent to refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update complaint'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

void _showResolvedPhoto(Map<String, dynamic>? resolvedPhoto) {
  if (resolvedPhoto != null && resolvedPhoto['image'] != null) {
    final imageUrl =
        'https://8250-122-172-86-111.ngrok-free.app${resolvedPhoto['image']}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No resolved photo available'),
    ));
  }
}


 @override
Widget build(BuildContext context) {
  final images = widget.complaint['photos'];
  final status = widget.complaint['status'];
  final createdAt = DateTime.parse(widget.complaint['created_at']).toLocal();
  final caption = widget.complaint['caption'];
  final resolvedPhoto = widget.complaint['resolved_photo'];

  return Container(
    margin: EdgeInsets.only(bottom: 16.0),
    width: 370,
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Auto-Scrolling Carousel Slider with Overlayed Date and Status
        Container(
          width: 370,
          height: 188.59,
          child: Stack(
            children: [
              // Carousel
              CarouselSlider(
                options: CarouselOptions(
                  height: 188.59,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                ),
                items: images.map<Widget>((image) {
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16), // Rounded corners
                    child: Container(
                      width: 370,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://8250-122-172-86-111.ngrok-free.app${image['image']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Date and Status Overlay
              // Date and Status Overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status
                      Container(
                        width: 110,
                        height: 26,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: ShapeDecoration(
                          color: status == "Resolved"
                              ? Colors.green
                              : Colors
                                  .orange, // Green for Resolved, Orange for Pending/Other
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            status,
                            style: TextStyle(
                              color: Colors
                                  .white, // White text for better readability
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Space between status and date
                      // Date
                      Container(
                        width: 78,
                        height: 26,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

            ],
          ),
        ),

        SizedBox(height: 8),
        // Location and Caption
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _address,
                      style: TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                caption,
                style: TextStyle(
                  color: Color(0xFF252525),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Conditional Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: ShapeDecoration(
              color: Color.fromARGB(255, 18, 137, 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: TextButton(
              onPressed: status == "Resolved"
                  ? () => _showResolvedPhoto(resolvedPhoto)
                  : _pickImage,
              child: Text(
                status == "Resolved" ? 'View Reply' : 'Reply with Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    ),
  );
}
}