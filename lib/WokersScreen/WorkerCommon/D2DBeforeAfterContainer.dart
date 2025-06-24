// WokersScreen/WorkerCommon/D2DBeforeAfterContainer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:slider_button/slider_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb

class D2DBeforeAfterContainer extends StatefulWidget {
  final String section;
  final Map<String, dynamic>? initialData;
  final Function onReload;

  const D2DBeforeAfterContainer(
      {Key? key,
      required this.section,
      this.initialData,
      required this.onReload})
      : super(key: key);

  @override
  _D2DBeforeAfterContainerState createState() =>
      _D2DBeforeAfterContainerState();
}

class _D2DBeforeAfterContainerState extends State<D2DBeforeAfterContainer> {
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _beforeImage;
  Map<String, dynamic>? _afterImage;

  bool _isBeforeSliderEnabled = false;
  bool _isAfterSliderEnabled = false;
  String activityId = '';
  final bool _isSubmitting = false;
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
    final String url =
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude";

    try {
      final response =
          await http.get(Uri.parse(url), headers: {"User-Agent": "FlutterApp"});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String fetchedAddress = data["display_name"] ?? "No address found";
        return fetchedAddress;
      } else {
        return "No address found";
      }
    } catch (e) {
      return "Error fetching address";
    }
  }

  Future<void> _submitBeforeImage() async {
    try {
      if (_beforeImage == null) return;

      String workerId = await getWorkerId();
      if (workerId.isEmpty) {
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
      } else {
        final errorData = await response.stream.bytesToString();
      }
    } catch (e) {
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

    // For PWAs, we need to convert the image to Base64.
    String imagePath;
    if (kIsWeb) {
      // Convert image to Base64 for PWA
      final bytes = await image.readAsBytes();
      imagePath = 'data:image/jpeg;base64,${base64Encode(bytes)}';
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
    if (_afterImage == null || activityId.isEmpty) {
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
                      decoration: const BoxDecoration(
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
                          color: const Color(0xFF1D1B20),
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
                          color: const Color(0x335C964A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            localizations.close,
                            style: TextStyle(
                              color: const Color(0xFF3E6632),
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
        throw 'Failed to submit activity. Try again later.';
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
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
          const SizedBox(height: 16),
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
                        border: Border.all(color: const Color(0xFF6B6B6B), width: 1),
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
                                const SizedBox(height: 8),
                                const Text(
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
                                          child: Center(
                                        child: Image.asset(
                                          'assets/images/cleaning.gif',
                                          width: 200,
                                          height: 200,
                                        ),
                                      ));
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
                                          child: Center(
                                        child: Image.asset(
                                          'assets/images/cleaning.gif',
                                          width: 200,
                                          height: 200,
                                        ),
                                      ));
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
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
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
                        border: Border.all(color: const Color(0xFF6B6B6B), width: 1),
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
                                const SizedBox(height: 8),
                                const Text(
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
                          : // PWA platform check
                          FutureBuilder<Uint8List>(
                              future:
                                  _loadImageBytes(_afterImage!['imagePath']!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: Center(
                                    child: Image.asset(
                                      'assets/images/cleaning.gif',
                                      width: 200,
                                      height: 200,
                                    ),
                                  ));
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
                          child: const Icon(Icons.close, color: Colors.red, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_beforeImage != null && !_isAfterSliderEnabled)
            SizedBox(
              height: 50.0,
              child: _isLoading
                  ? Center(
                      child: Center(
                        child: Image.asset(
                          'assets/images/Loder.gif',
                          width: 200,
                          height: 200,
                        ),
                      ),
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
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        return null;
                      },
                      label: Text(
                        localizations.slideToConfirmBefore,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      icon: Image.asset(
                        'assets/images/Icon.png', // Replace with your image path
                        width: 40, // Adjust the size as needed
                        height: 40,
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      backgroundColor: const Color(0xFF5C964A),
                      buttonColor: Colors.white,
                      radius: 30,
                    ),
            ),
          if (_afterImage != null && !_isSubmitting)
            SizedBox(
              height: 50.0,
              child: _isLoading
                  ? Center(
                      child: Center(
                        child: Image.asset(
                          'assets/images/Loder.gif',
                          width: 200,
                          height: 200,
                        ),
                      ),
                    )
                  : SliderButton(
                      action: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await _submitAfterImage();
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        return null;
                      },
                      label: Text(
                        localizations.slideToConfirmAfter,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      icon: Image.asset(
                        'assets/images/Icon.png', // Replace with your image path
                        width: 40, // Adjust the size as needed
                        height: 40,
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      backgroundColor: const Color(0xFF5C964A),
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
