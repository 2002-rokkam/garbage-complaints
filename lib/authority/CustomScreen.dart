// authority/CustomScreen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:slider_button/slider_button.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slider_button/slider_button.dart'; // Import the slider_button package

class ResponsiveScreen extends StatefulWidget {
  @override
  _ResponsiveScreenState createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  List<Widget> beforeAfterContainers = [];

  void addNewContainer() {
    setState(() {
      beforeAfterContainers.add(BeforeAfterContainer());
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
                BeforeAfterContainer(), // Initial container
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
// Import the slider_button package

class BeforeAfterContainer extends StatefulWidget {
  @override
  _BeforeAfterContainerState createState() => _BeforeAfterContainerState();
}

class _BeforeAfterContainerState extends State<BeforeAfterContainer> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _beforeImages = [];
  List<Map<String, dynamic>> _afterImages = [];

  Future<void> _captureImage(String type) async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Position position = await _getCurrentLocation();

    // Store image and location data
    Map<String, dynamic> imageData = {
      'imagePath': image.path,
      'latitude': position.latitude,
      'longitude': position.longitude,
    };

    setState(() {
      if (type == 'before') {
        _beforeImages.add(imageData);
      } else {
        _afterImages.add(imageData);
      }
    });
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
                onTap: () => _captureImage('before'),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6B6B6B), width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _beforeImages.isEmpty
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
                          File(_beforeImages.last['imagePath']),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              GestureDetector(
                onTap: () => _captureImage('after'),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6B6B6B), width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _afterImages.isEmpty
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
                          File(_afterImages.last['imagePath']),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Replace the button with the swipe slider button
          SliderButton(
            action: () async {
              // Action to perform when slider is successfully slid
              print("Payment successful");
              // You can replace this with any other function or navigation
            },
            label: Text(
              "Slide to Complete",
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
