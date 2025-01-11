// WokersScreen/WorkerCommon/BeforeAfterContainer.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:slider_button/slider_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeforeAfterContainer extends StatefulWidget {
  final String section;
  final Map<String, dynamic>? initialData;
  final Function onReload;

  const BeforeAfterContainer(
      {Key? key,
      required this.section,
      this.initialData,
      required this.onReload})
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
  String activityId = '';
  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      activityId = widget.initialData!['record_id'].toString();

      if (widget.initialData!['before_image'] != null) {
        _beforeImage = {
          'imagePath': widget.initialData!['before_image'],
          'latitude': widget.initialData!['latitude_before'],
          'longitude': widget.initialData!['longitude_before'],
          'address': widget.initialData!['address'],
        };
      }

      if (widget.initialData!['status'] == 'trip started') {
        _isAfterSliderEnabled = true;
      }

      if (widget.initialData!['after_image'] != null) {
        _afterImage = {
          'imagePath': widget.initialData!['after_image'],
          'latitude': widget.initialData!['latitude_after'],
          'longitude': widget.initialData!['longitude_after'],
          'address': widget.initialData!['address'],
        };
      }
    } else {
      _isBeforeSliderEnabled = true;
      _isAfterSliderEnabled = false;
    }
  }

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
        print(response);
        setState(() {
          activityId = response.data['data']['record_id'].toString();
        });
        widget.onReload();

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
      Response response = await dio.put(
          'https://c035-122-172-86-134.ngrok-free.app/api/submit-activity',
          data: formData);

      if (response.statusCode == 200) {
        print("After image submitted successfully!");

        // Show custom popup
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissal by tapping outside
          builder: (BuildContext context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: screenWidth * 0.9, // 90% of screen width
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight *
                      0.05, // Adjust vertical padding based on height
                  horizontal: screenWidth *
                      0.05, // Adjust horizontal padding based on width
                ),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Adjust height based on children
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.3, // 30% of screen width
                      height: screenWidth * 0.3, // Maintain square aspect ratio
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Image.asset(
                        'images/done.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * 0.03), // Spacing based on height
                    SizedBox(
                      width: screenWidth * 0.8, // 80% of screen width
                      child: Text(
                        'Successfully Submited!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1D1B20),
                          fontSize: screenWidth *
                              0.06, // Font size relative to screen width
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * 0.04), // Spacing based on height
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Close the popup
                        widget.onReload(); // Reload the screen
                      },
                      child: Container(
                        width: screenWidth *
                            0.25, // Button width relative to screen
                        height: screenHeight *
                            0.05, // Button height relative to screen
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
                              fontSize: screenWidth *
                                  0.035, // Font size relative to screen width
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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

  Future<bool> _isAfterImageWithinRadius() async {
    if (_beforeImage == null || _afterImage == null) {
      return false;
    }

    double beforeLatitude = _beforeImage!['latitude'];
    double beforeLongitude = _beforeImage!['longitude'];

    double afterLatitude = _afterImage!['latitude'];
    double afterLongitude = _afterImage!['longitude'];

    // Calculate the distance using Geolocator (or any other method you prefer)
    double distance = await Geolocator.distanceBetween(
        beforeLatitude, beforeLongitude, afterLatitude, afterLongitude);

    // Check if the distance is within the 50 meters radius
    return distance <= 50.0; // Return true if within 50 meters, otherwise false
  }

  void _showPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'images/d2d.png',
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
                onTap: _isBeforeSliderEnabled && _beforeImage == null
                    ? () => _captureImage('before')
                    : null,
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
                                  'images/Camera.png',
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
                          : _beforeImage!['imagePath']!.startsWith('https')
                              ? Image.network(
                                  '${_beforeImage!['imagePath']}',
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    return Center(
                                        child: Text('Failed to load image'));
                                  },
                                )
                              : Image.file(
                                  File(_beforeImage!['imagePath']!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    return Center(
                                        child: Text('Failed to load image'));
                                  },
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
                                  'images/Camera.png',
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
                              File(_afterImage!['imagePath']!),
                              fit: BoxFit.cover,
                              
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Center(
                                    child: Text('Failed to load image'));
                              },
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
            Container(
              height: 50.0,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SliderButton(
                      action: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _submitBeforeImage();
                          setState(() {
                            _isBeforeSliderEnabled = false;
                            _isAfterSliderEnabled = true;
                          });
                        } catch (e) {
                          print("Error in slider action: $e");
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
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
                    ),
            ),
          if (_afterImage != null && !_isSubmitting)
            Container(
                height: 50.0,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SliderButton(
                        action: () async {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            // Check distance only after the slider is moved
                            bool isWithinRadius =
                                await _isAfterImageWithinRadius();

                            if (isWithinRadius) {
                              await _submitAfterImage();
                            } else {
                              // Show popup if the after image is not within the 50-meter radius
                              _showPopup(
                                  'Error: After image is too far from the before image.');
                            }
                          } catch (e) {
                            print("Error in slider action: $e");
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
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
                      )),
        ],
      ),
    );
  }
}
