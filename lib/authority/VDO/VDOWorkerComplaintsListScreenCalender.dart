// authority/VDO/VDOWorkerComplaintsListScreenCalender.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class VDOWorkerComplaintsListScreenCalender extends StatelessWidget {
  final DateTime date;
  final List<dynamic> complaints;
  final VoidCallback onUpdate;

  VDOWorkerComplaintsListScreenCalender(
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
        backgroundColor: Color(0xFF5C964A),
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

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";
    return workerId;
  }

  Future<void> _loadWorkerDetails() async {
    workerId = await getWorkerId();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {});
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
    try {
      Response response = await dio.post(
        'https://sbmgrajasthan.com/api/update-complaint/${widget.complaint['complaint_id']}',
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
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // Set the background color to green
                  ),
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

  void _showFullScreenImage(
      String imageUrl, double dirlatitude, double dirlongitude) async {
    final createdAt = DateTime.parse(widget.complaint['created_at']).toLocal();
    String time = '${createdAt.hour}:${createdAt.minute}:${createdAt.second}';
    String location =
        'Lat: ${dirlatitude.toStringAsFixed(6)}, Long: ${dirlongitude.toStringAsFixed(6)}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image with interactive zoom
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Time overlay below the image
                  Container(
                    width: 370,
                    height: 45,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.23),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w700,
                            height: 1.43,
                            letterSpacing: 0.14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Location (Latitude & Longitude) below the time
                  Container(
                    width: 370,
                    height: 45,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.23),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.43,
                            letterSpacing: 0.14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showVerifyConfirmation(String complaintId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                "Confirm Verification",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to verify this complaint?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _verifyComplaint(complaintId);
              },
              child: Text("Yes, Verify"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyComplaint(String complaintId) async {
    final url = Uri.parse(
        'https://sbmgrajasthan.com/api/complaint/$complaintId/verify');
    print(complaintId);
    print(workerId);
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"verifier_id": workerId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complaint verified successfully!')),
        );
        widget.onUpdate();
        Navigator.pop(context, true); // Refresh the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.complaint['photos'];
    final status = widget.complaint['status'];
    print(widget.complaint);
    final createdAt = DateTime.parse(widget.complaint['created_at']).toLocal();
    final caption = widget.complaint['caption'];
    final resolvedPhoto = widget.complaint['resolved_photo'];
    final dirlatitude = widget.complaint['photos'][0]['latitude'];
    final dirlongitude = widget.complaint['photos'][0]['longitude'];
    String time = '${createdAt.hour}:${createdAt.minute}:${createdAt.second}';

    int activeIndex = 0;
    final PageController _pageController = PageController();

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
          Container(
            width: 370,
            height: 188.59,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _showFullScreenImage(
                            images[index]['image'], dirlatitude, dirlongitude);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 370,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(images[index]['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 12,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: images.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.black,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 2,
                    ),
                  ),
                ),
                // Date and Status Overlay
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 26,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: ShapeDecoration(
                          color: status == "Resolved" || status == "Verified"
                              ? Color(0xFF5C964A)
                              : Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            status,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 128,
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
                            '$time,${createdAt.day}/${createdAt.month}/${createdAt.year}',
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
                    // Location Redirect Icon
                    TextButton(
                      onPressed: () {
                        if (dirlatitude != null && dirlongitude != null) {
                          final url = Uri.parse(
                              'https://www.google.com/maps?q=$dirlatitude,$dirlongitude');
                          _launchURL(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Location not available'),
                          ));
                        }
                      },
                      child: Text(
                        'Open Map',
                        style: TextStyle(color: Colors.black, fontSize: 16),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: resolvedPhoto != null && resolvedPhoto['image'] != null
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: ShapeDecoration(
                            color: Color(0xFF5C964A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () => _showResolvedPhoto(resolvedPhoto),
                            child: Text(
                              'View Reply',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (status == "Resolved") ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: ShapeDecoration(
                              color: Color(0xFF5C964A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                _showVerifyConfirmation(
                                    widget.complaint['complaint_id']);
                              },
                              child: Text(
                                'Verify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : SizedBox(),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
