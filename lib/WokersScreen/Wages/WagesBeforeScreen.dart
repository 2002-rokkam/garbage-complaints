// WokersScreen/Wages/WagesBeforeScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WagesBeforeScreen extends StatefulWidget {
  final String section;
  final Function onReload;

  const WagesBeforeScreen({
    Key? key,
    required this.section,
    required this.onReload,
  }) : super(key: key);

  @override
  _WagesBeforeScreenState createState() => _WagesBeforeScreenState();
}

class _WagesBeforeScreenState extends State<WagesBeforeScreen> {
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _beforeImage;
  bool _isLoading = false;

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";
    return workerId;
  }

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

      String workerId = await getWorkerId();
      if (workerId == "") {
        print("Error: worker_id not found in SharedPreferences.");
        return;
      }

      double latitude = _beforeImage!['latitude'];
      double longitude = _beforeImage!['longitude'];

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
        'https://c035-122-172-86-134.ngrok-free.app/api/submit-activity',
        data: formData,
      );

      if (response.statusCode == 201) {
        setState(() {
          _beforeImage = null;
        });
        widget.onReload();
        _showSuccessDialog();
      } else {
        print("Error: ${response.data['message']}");
      }
    } catch (e) {
      print("Error submitting before image: $e");
    }
  }

  Future<void> _captureImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Position position = await _getCurrentLocation();

    String address =
        await _getAddressFromLatLong(position.latitude, position.longitude);

    Map<String, dynamic> imageData = {
      'imagePath': image.path,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': address,
    };

    setState(() {
      _beforeImage = imageData;
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

  void _deleteImage() {
    setState(() {
      _beforeImage = null;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.05,
              horizontal: screenWidth * 0.05,
            ),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'images/done.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: Text(
                    'Successfully uploaded receipt!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: screenWidth * 0.06,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onReload();
                  },
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: ShapeDecoration(
                      color: Color(0x335C964A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF3E6632),
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          SizedBox(height: 16),
          GestureDetector(
            onTap: _beforeImage == null ? _captureImage : null,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6B6B6B), width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _beforeImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/Camera.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload Recepit',
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
                if (_beforeImage != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _deleteImage,
                      child: Icon(Icons.close, color: Colors.red, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          if (_beforeImage != null)
            Container(
              height: 50.0,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _submitBeforeImage();
                        } catch (e) {
                          print("Error in button action: $e");
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF5C964A), // Button background color
                        onPrimary: Colors.white, // Button text color
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            50), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Button radius
                        ),
                      ),
                      child: Text(
                        "Upload Receipt",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
            )
        ],
      ),
    );
  }
}
