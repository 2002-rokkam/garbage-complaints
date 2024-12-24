// authority/CustomScreen.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';  // For API calls
import 'dart:io';
import 'package:slider_button/slider_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponsiveScreen extends StatefulWidget {
  final String section;

  const ResponsiveScreen({Key? key, required this.section}) : super(key: key);
  @override
  _ResponsiveScreenState createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  List<Widget> beforeAfterContainers = [];

  void addNewContainer() {
    setState(() {
      beforeAfterContainers.add(BeforeAfterContainer(section: widget.section));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5C964A),
        title: Text('App Header'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                BeforeAfterContainer(section: widget.section),
                ...beforeAfterContainers,
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: addNewContainer,
              backgroundColor: Color(0xFFFFD262),
              label: Row(
                children: [
                  FlutterLogo(size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Add More',
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 14,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BeforeAfterContainer extends StatefulWidget {
    final String section;

  const BeforeAfterContainer({Key? key, required this.section})
      : super(key: key);
  @override
  _BeforeAfterContainerState createState() => _BeforeAfterContainerState();
}

class _BeforeAfterContainerState extends State<BeforeAfterContainer> {
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _beforeImage;
  Map<String, dynamic>? _afterImage;

  bool _isBeforeSliderEnabled = false;
  bool _isAfterSliderEnabled = false;
  String activityId = '';  // Placeholder for the activity ID
// Helper function to get the worker_id from SharedPreferences
  Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
    return workerId;
  }

// Helper function to make API call for the before image
  Future<String> _getAddressFromLatLong(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      } else {
        return "No address found";
      }
    } catch (e) {
      print("Error fetching address: $e");
      return "Error fetching address";
    }
  }

  Future<void> _submitBeforeImage() async {
    try {
      if (_beforeImage == null) return;

      int workerId = await getWorkerId();
      if (workerId == -1) {
        print("Error: worker_id not found in SharedPreferences.");
        return;
      }

      double latitude = _beforeImage!['latitude'];
      double longitude = _beforeImage!['longitude'];

      // Fetch the address
      String address = await _getAddressFromLatLong(latitude, longitude);

      FormData formData = FormData.fromMap({
        'worker_id': workerId,
        'section': widget.section,
        'before_image':
            await MultipartFile.fromFile(_beforeImage!['imagePath']),
        'latitude_before': latitude,
        'longitude_before': longitude,
        'status': 'trip started',
        'address': address,
      });

      Dio dio = Dio();
      Response response = await dio.post(
        'https://cc8b-2401-4900-882f-6635-1516-9fae-e339-4326.ngrok-free.app/api/submit-activity',
        data: formData,
      );

      if (response.statusCode == 200) {
        setState(() {
          activityId = response.data['data']['id'].toString();
        });
        print("Activity created successfully!");
      } else {
        print("Error: ${response.data['message']}");
      }
    } catch (e) {
      print("Error submitting before image: $e");
    }
  }

  Future<void> _captureImage(String type) async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Position position = await _getCurrentLocation();

    // Fetch address for the captured coordinates
    String address =
        await _getAddressFromLatLong(position.latitude, position.longitude);

    Map<String, dynamic> imageData = {
      'imagePath': image.path,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': address,
    };

    setState(() {
      if (type == 'before') {
        _beforeImage = imageData;
        _isBeforeSliderEnabled = true;
      } else if (type == 'after') {
        _afterImage = imageData;
      }
    });
  }


  // Helper function to make API call for after image
  Future<void> _submitAfterImage() async {
    try {
      print("Submitting After Image...");
      print("Activity ID: $activityId");
      print("After Image Data: $_afterImage");

      if (_afterImage == null || activityId.isEmpty) {
        print("Error: After image data or activity ID is missing.");
        return;
      }
      FormData formData = FormData.fromMap({
        'activity_id': activityId,
        'after_image': await MultipartFile.fromFile(_afterImage!['imagePath']),
        'latitude_after': _afterImage!['latitude'],
        'longitude_after': _afterImage!['longitude'],
        'status': 'Completed',
      });

      Dio dio = Dio();
      Response response = await dio.put('https://cc8b-2401-4900-882f-6635-1516-9fae-e339-4326.ngrok-free.app/api/submit-activity/', data: formData);

      if (response.statusCode == 200) {
        print("After image submitted successfully!");
      } else {
        print("Error: ${response.data['message']}");
      }
    } catch (e) {
      print("Error submitting after image: $e");
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void _deleteImage(String type) {
    setState(() {
      if (type == 'before') {
        _beforeImage = null;
        _isBeforeSliderEnabled = false;
        _isAfterSliderEnabled = false;
      } else if (type == 'after') {
        _afterImage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'images/CSC.png',
                width: 24,
                height: 24,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _beforeImage == null ? () => _captureImage('before') : null,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF6B6B6B), width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _beforeImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/CSC.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Before',
                                  style: TextStyle(
                                    color: Color(0xFF6B6B6B),
                                    fontSize: 14,
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          : Image.file(
                              File(_beforeImage!['imagePath']),
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (_beforeImage != null && !_isAfterSliderEnabled)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage('before'),
                          child: Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                                onTap:
                    _isAfterSliderEnabled ? () => _captureImage('after') : null,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF6B6B6B), width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _afterImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'images/CSC.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'After',
                                  style: TextStyle(
                                    color: Color(0xFF6B6B6B),
                                    fontSize: 14,
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          : Image.file(
                              File(_afterImage!['imagePath']),
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (_afterImage != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage('after'),
                          child: Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_beforeImage != null && !_isAfterSliderEnabled)
            SliderButton(
              action: () async {
                if (!mounted) return; // Ensure the widget is still in the tree
                setState(() {
                  _isAfterSliderEnabled = true;
                });

                // Submit before image to the server
                await _submitBeforeImage();
              },
              label: Text(
                "Slide to confirm 'Before'",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              icon: Icon(Icons.check, color: Colors.white),
              width: MediaQuery.of(context).size.width * 0.8,
              backgroundColor: Color(0xFF5C964A),
              buttonColor: Colors.white,
              radius: 30,
              highlightedColor: Color(0xFF4C8431),
              baseColor: Colors.green,
            ),
          if (_afterImage != null)
            SliderButton(
              action: () async {
                try {
                  if (!mounted) return;
                  await _submitAfterImage();
                  print("After image slider action completed.");
                } catch (e) {
                  print("Error in slider action: $e");
                }
              },
              label: Text(
                "Slide to confirm 'After'",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              icon: Icon(Icons.check, color: Colors.white),
              width: MediaQuery.of(context).size.width * 0.8,
              backgroundColor: Color(0xFF5C964A),
              buttonColor: Colors.white,
              radius: 30,
              highlightedColor: Color(0xFF4C8431),
              baseColor: Colors.green,
            ),

        ],
      ),
    );
  }
}

