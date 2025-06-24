// WokersScreen/Wages/WagesBeforeScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  late Locale _locale;

  @override
  void initState() {
    super.initState();
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
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
      if (workerId == "") {
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
        'https://sbmgrajasthan.com/api/submit-activity',
        data: formData,
      );

      if (response.statusCode == 201) {
        setState(() {
          _beforeImage = null;
        });
        widget.onReload();
        _showSuccessDialog();
      } else {}
    } catch (e) {}
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _captureImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _captureImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    XFile? image = await _picker.pickImage(source: source);
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
    final localizations = AppLocalizations.of(context)!;
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
                  decoration: const BoxDecoration(),
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
                    'Successfully uploaded receipt!',
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
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _beforeImage == null ? _showImageSourceDialog : null,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
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
                              'Upload Receipt',
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
                      child: const Icon(Icons.close, color: Colors.red, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_beforeImage != null)
            SizedBox(
              height: 50.0,
              child: _isLoading
                  ? Center(
                      child: Image.asset(
                        'assets/images/Loder.gif',
                        width: 200,
                        height: 200,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _submitBeforeImage();
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF5C964A),
                        minimumSize:
                            Size(MediaQuery.of(context).size.width * 0.8, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
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
