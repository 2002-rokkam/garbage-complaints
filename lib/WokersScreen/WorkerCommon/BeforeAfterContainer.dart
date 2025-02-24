// WokersScreen/WorkerCommon/BeforeAfterContainer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
     _loadLanguagePreference();
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
      if (workerId.isEmpty) {
        print("Error: worker_id not found in SharedPreferences.");
        return;
      }

      double latitude = _beforeImage!['latitude'];
      double longitude = _beforeImage!['longitude'];

      String address = await _getAddressFromLatLong(latitude, longitude);

      var uri = Uri.parse('https://sbmgrajasthan.com/api/submit-activity');
      var request = http.MultipartRequest('POST', uri)
        ..fields['worker_id'] = workerId
        ..fields['section'] = widget.section
        ..fields['latitude_before'] = latitude.toString()
        ..fields['longitude_before'] = longitude.toString()
        ..fields['status'] = 'trip started'
        ..fields['address'] = address;

      if (kIsWeb) {
        XFile image = XFile(_beforeImage!['imagePath']);
        Uint8List imageBytes = await image.readAsBytes();
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        request.files.add(http.MultipartFile.fromBytes(
          'before_image',
          imageBytes,
          filename: 'before_image_$timestamp.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'before_image',
          _beforeImage!['imagePath'],
        ));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        setState(() {
          activityId = jsonResponse['data']['record_id'].toString();
        });
        widget.onReload();

        print("Activity created successfully!");
      } else {
        final errorData = await response.stream.bytesToString();
        print("Error response: $errorData");
      }
    } catch (e) {
      print("Error submitting before image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _captureImage(String type) async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Position position = await _getCurrentLocation();

    String address =
        await _getAddressFromLatLong(position.latitude, position.longitude);
    String imagePath;
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      imagePath = 'data:image/jpeg;base64,' + base64Encode(bytes);
    } else {
      imagePath = image.path;
    }

    Map<String, dynamic> imageData = {
      'imagePath': imagePath,
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
    print("Submitting after image... _afterImage: $_afterImage, activityId: $activityId");
    if (_afterImage == null || activityId.isEmpty) {
      print("Error: After image data or activity ID is missing.");
      return;
    }

    try {
      var uri = Uri.parse('https://sbmgrajasthan.com/api/submit-activity');
      var request = http.MultipartRequest('PUT', uri)
        ..fields['activity_id'] = activityId
        ..fields['latitude_after'] = _afterImage!['latitude'].toString()
        ..fields['longitude_after'] = _afterImage!['longitude'].toString()
        ..fields['status'] = 'Completed';
      if (kIsWeb) {
        XFile image = XFile(_afterImage!['imagePath']);
        Uint8List imageBytes = await image.readAsBytes();
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        request.files.add(http.MultipartFile.fromBytes(
          'after_image',
          imageBytes,
          filename: 'after_image_$timestamp.jpg',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'after_image',
          _afterImage!['imagePath'],
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        print("After image submitted successfully!");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final localizations = AppLocalizations.of(context)!;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/done.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Text(
                        localizations.successfullySubmitted,
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
                            localizations.close,
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
      } else {
        final errorData = await response.stream.bytesToString();
        print("Error response: $errorData");
        throw 'Failed to submit activity. Try again later.';
      }
    } catch (e) {
      print("Error submitting after image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    if (kIsWeb) {
      return Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else if (Platform.isAndroid || Platform.isIOS) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      throw 'Platform not supported for geolocation.';
    }
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

    double distance = await Geolocator.distanceBetween(
        beforeLatitude, beforeLongitude, afterLatitude, afterLongitude);

    return distance <= 20.0;
  }

  void _showPopup(String message) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.error),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onReload();
            },
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                'assets/images/d2d.png',
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
                                  'assets/images/Camera.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  localizations.before,
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
                                        child: Text(
                                            localizations.failedToLoadImage));
                                  },
                                )
                              : // PWA platform check
                              FutureBuilder<Uint8List>(
                                  future: _loadImageBytes(
                                      _beforeImage!['imagePath']!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              localizations.failedToLoadImage));
                                    } else if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                              child: Text(localizations
                                                  .failedToLoadImage));
                                        },
                                      );
                                    } else {
                                      return Center(
                                          child:
                                              Text(localizations.noImageData));
                                    }
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
                                  'assets/images/Camera.png',
                                  width: 24,
                                  height: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  localizations.after,
                                  style: TextStyle(
                                    color: Color(0xFF6B6B6B),
                                    fontSize: 14,
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            )
                          : // PWA platform check
                          FutureBuilder<Uint8List>(
                              future:
                                  _loadImageBytes(_afterImage!['imagePath']!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          localizations.failedToLoadImage));
                                } else if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                          child: Text(
                                              localizations.failedToLoadImage));
                                    },
                                  );
                                } else {
                                  return Center(
                                      child: Text(localizations.noImageData));
                                }
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
                        localizations.slideToConfirmBefore,
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
                          bool isWithinRadius =
                              await _isAfterImageWithinRadius();
                          if (isWithinRadius) {
                            await _submitAfterImage();
                          } else {
                            _showPopup(localizations.errorImageTooFar);
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
                        localizations.slideToConfirmAfter,
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

  Future<Uint8List> _loadImageBytes(String imagePath) async {
    if (imagePath.startsWith('data:image')) {
      return base64Decode(imagePath.split(',').last);
    } else {
      final file = File(imagePath);
      return await file.readAsBytes();
    }
  }
}
