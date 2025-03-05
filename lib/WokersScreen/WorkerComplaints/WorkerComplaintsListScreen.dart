// WokersScreen/WorkerComplaints/WorkerComplaintsListScreen.dart
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
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WorkerComplaintsListScreen extends StatelessWidget {
  final DateTime date;
  final List<dynamic> complaints;
  final VoidCallback onUpdate;

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
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
                  onUpdate: onUpdate,
                );
              },
            ),
    );
  }
}

class ComplaintCard extends StatefulWidget {
  final dynamic complaint;
  final VoidCallback onUpdate;

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
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAddress();
    _loadWorkerDetails();
    _loadLanguagePreference();
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
                      Navigator.of(context).pop();
                      _submitFormData();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _imageFile = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
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
      _showErrorDialog('Please select an image and allow location access');
      return;
    }

    final complaintLatitude = widget.complaint['photos'][0]['latitude'];
    final complaintLongitude = widget.complaint['photos'][0]['longitude'];

    if (complaintLatitude == null || complaintLongitude == null) {
      _showErrorDialog('Complaint location data is missing');
      return;
    }
    double distance = await Geolocator.distanceBetween(
      complaintLatitude,
      complaintLongitude,
      _latitude!,
      _longitude!,
    );

    if (distance > 15) {
      _showErrorDialog(
          'You must be within 10 meters of the complaint location to submit a reply.');
      return;
    }

    Dio dio = Dio();
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueFilename = 'solved_complaint_image_$timestamp.jpg';

    FormData formData = FormData.fromMap({
      'solved_image': await MultipartFile.fromFile(
        _imageFile!.path,
        filename: uniqueFilename,
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
        Navigator.pop(context, true);
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

  void _showErrorDialog(String message) {
    final localizations = AppLocalizations.of(context)!;
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
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text(localizations.ok),
              ),
            ],
          ),
        );
      },
    );
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
                    primary: Colors.green,
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
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final images = widget.complaint['photos'];
    final status = widget.complaint['status'];
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
                        width: 138,
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
                    TextButton(
                      onPressed: () {
                        if (dirlatitude != null && dirlongitude != null) {
                          final url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$dirlatitude,$dirlongitude');
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
                onPressed: (status == "Resolved" || status == "Verified")
                    ? () => _showResolvedPhoto(resolvedPhoto)
                    : _pickImage,
                child: Text(
                  (status == "Resolved" || status == "Verified")
                      ? 'View Reply'
                      : 'Reply with Image',
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
