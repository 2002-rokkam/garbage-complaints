// authority/CustomScreen.dart
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      isLoading = true;
    });

    Future<int> getWorkerId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int workerId = prefs.getInt('worker_id') ?? -1;
      return workerId;
    }

    try {
      int workerId = await getWorkerId();
      Dio dio = Dio();
      final response = await dio.get(
          'https://f827-2401-4900-882e-cef3-39e1-4161-da52-3ce0.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

      if (response.statusCode == 200) {
        final data = response.data;
        List activities = data['activities'];

        setState(() {
          beforeAfterContainers = activities
              .where((activity) => activity['status'] == 'trip started')
              .map((activity) => BeforeAfterContainer(
                    section: widget.section,
                    initialData: activity,
                    onReload: _fetchActivities,
                  ))
              .toList();
        });
      } else {
        print("Error fetching activities: ${response.data['message']}");
      }
    } catch (e) {
      print("Error fetching activities: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addNewContainer() {
    setState(() {
      beforeAfterContainers.add(BeforeAfterContainer(
        section: widget.section,
        initialData: null,
        onReload: _fetchActivities,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFF5C964A),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                '${widget.section}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: isLoading
              ? [Center(child: CircularProgressIndicator())]
              : beforeAfterContainers.isNotEmpty
                  ? beforeAfterContainers
                  : [
                      BeforeAfterContainer(
                        section: widget.section,
                        onReload: _fetchActivities,
                      ),
                    ],
        ),
      ),
      // Floating action button will stay fixed at the bottom of the screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewContainer,
        backgroundColor: Color(0xFFFFD262),
        label: Row(
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: Color(0xFF252525),
            ),
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
    );
  }
}

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
      activityId = widget.initialData!['id'].toString();

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

  Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
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

      int workerId = await getWorkerId();
      if (workerId == -1) {
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
        'https://f827-2401-4900-882e-cef3-39e1-4161-da52-3ce0.ngrok-free.app/api/submit-activity',
        data: formData,
      );

      if (response.statusCode == 201) {
        setState(() {
          activityId = response.data['data']['id'].toString();
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
          'https://f827-2401-4900-882e-cef3-39e1-4161-da52-3ce0.ngrok-free.app/api/submit-activity',
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
                        'Successfully uploaded receipt!',
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
                          await _submitAfterImage();
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
                    ),
            ),
        ],
      ),
    );
  }
}
