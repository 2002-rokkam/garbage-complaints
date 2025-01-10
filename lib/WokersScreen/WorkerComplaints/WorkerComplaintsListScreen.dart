// WokersScreen/WorkerComplaints/WorkerComplaintsListScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerComplaintsListScreen extends StatelessWidget {
  final DateTime date;
  final List<dynamic> complaints;
  final VoidCallback onUpdate; // Callback to refresh data

  WorkerComplaintsListScreen(
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
        title: Text(
          'Complaints on ${date.toLocal()}'.split(' ')[0],
          style: TextStyle(
            color: Colors.white, // White text color
            fontSize: 20, // Optional: Adjust font size
            fontWeight: FontWeight.bold, // Optional: Bold text
          ),
        ),
        backgroundColor: Color(0xFF5C964A), // Set green color for the app bar
        toolbarHeight: 80.0,
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
  late String workerId;
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
      print(_latitude);
      print(_longitude);
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

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";
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
      'solved_image': await MultipartFile.fromFile(
        _imageFile!.path,
        filename: 'solved_complaint_image11111.jpg',
      ),
      'solved_lat': _latitude,
      'solved_long': _longitude,
      'worker_id': workerId,
    });
    print(formData);
    try {
      Response response = await dio.post(
        'https://c035-122-172-86-134.ngrok-free.app/api/update-complaint/${widget.complaint['complaint_id']}',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Complaint updated successfully'),
        ));
        widget.onUpdate();
        Navigator.pop(context, true); // Notify parent to refresh data
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
      final imageUrl = '${resolvedPhoto['image']}';

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
                              '${image['image']}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
                              ? Color(0xFF5C964A)
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
                color: Color(0xFF5C964A),
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
