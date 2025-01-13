// CitizensScreen/ComplaintsScreen/ComplaintScreen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../RotatingTrashBinLoader.dart';
import 'ComplaintRegisterScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  late String _idToken;
  String? selectedDistrict;
  String? selectedGP;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> imageData = [];
  bool isLoading = false; // Added loading state

  @override
  void initState() {
    super.initState();
    _loadTokenFromSharedPrefs();
    fetchDistricts();
  }

  Future<void> _loadTokenFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? idToken = prefs.getString('id_token');
    if (idToken != null) {
      setState(() {
        _idToken = idToken;
      });
    } else {
      // Handle missing token (e.g., redirect to login screen)
      throw 'Token not found. Please log in again.';
    }
  }

  Future<void> submitComplaint() async {
    if (selectedDistrict != null &&
        selectedGP != null &&
        imageData.isNotEmpty) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
      });

      String formattedDistrict = selectedDistrict!.replaceAll(' ', '_');
      String formattedGramPanchayat = selectedGP!.replaceAll(' ', '_');

      // Change letter after underscore to lowercase
      formattedDistrict =
          formattedDistrict.replaceAllMapped(RegExp(r'_(.)'), (match) {
        return '_${match.group(1)?.toLowerCase()}';
      });

      formattedGramPanchayat =
          formattedGramPanchayat.replaceAllMapped(RegExp(r'_(.)'), (match) {
        return '_${match.group(1)?.toLowerCase()}';
      });
      print(formattedDistrict);

      print(formattedGramPanchayat);
      try {
        var uri = Uri.parse('http://167.71.230.247/api/complaints-register');

        var request = http.MultipartRequest('POST', uri)
          ..fields['district'] = formattedDistrict
          ..fields['gram_panchayat'] = formattedGramPanchayat
          ..fields['caption'] = caption;

        for (int i = 0; i < imageData.length; i++) {
          var image = imageData[i]['image'] as Uint8List;
          var latitude = imageData[i]['latitude'].toString();
          var longitude = imageData[i]['longitude'].toString();

          // Generate a unique filename using the current timestamp
          var timestamp = DateTime.now().millisecondsSinceEpoch;
          var filename = 'photo${i + 1}_$timestamp.jpg';

          request.files.add(http.MultipartFile.fromBytes(
            'photos',
            image,
            filename: filename,
          ));

          request.fields['latitude_$filename'] = latitude;
          request.fields['longitude_$filename'] = longitude;
        }

        request.headers['Authorization'] = 'token $_idToken';

        var response = await request.send();

        if (response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseData);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ComplaintRegisterScreen()),
          );
        } else {
          throw 'Failed to submit complaint. Try again later.';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details.")),
      );
    }
  }

  String caption = '';

  Future<Position> _determinePosition() async {
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

  bool hasCapturedImage = false;

  Future<void> _pickImage() async {
    if (imageData.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only capture up to 3 images.")),
      );
      return;
    }

    try {
      final pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        final position = await _determinePosition();
        final imageBytes = await pickedFile.readAsBytes();

        setState(() {
          imageData.add({
            'image': imageBytes,
            'caption': caption,
            'latitude': position.latitude,
            'longitude': position.longitude,
          });
          hasCapturedImage = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

// 2. Delete Image with Confirmation Dialog
  Future<void> _deleteImage(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        imageData.removeAt(index); // Remove the image from the list
      });
    }
  }

  void _showSheet(
      String title, List<String> options, Function(String) onSelect) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredOptions = List.from(options);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7, // Starts at 50% of the screen height
              minChildSize: 0.7, // Minimum size is 50% of the screen height
              maxChildSize: 0.7, // Maximum size is 90% of the screen height
              expand: false,
              builder: (_, controller) => Column(
                children: [
                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search $title",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (query) {
                        setModalState(() {
                          filteredOptions = options
                              .where((option) => option
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: filteredOptions.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(filteredOptions[index]),
                          onTap: () {
                            onSelect(filteredOptions[index]);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<String> districts = [];

  List<String> gramPanchayats = [];

  final String districtsUrl = "http://167.71.230.247/api/getDistricts";
  final String gpUrl = "http://167.71.230.247/api/getGpComplaints";

  Future<void> fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse(districtsUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          districts = List<String>.from(data['districts']);
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> fetchGramPanchayats(String selectedDistrict) async {
    try {
      // Send selected district as a query parameter to fetch the gram panchayats
      final response =
          await http.get(Uri.parse('$gpUrl/?district=$selectedDistrict'));

      if (response.statusCode == 200) {
        // Parse the response to extract gram panchayats
        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the district matches the selected one
        if (data['district'] == selectedDistrict) {
          setState(() {
            gramPanchayats = List<String>.from(data['gram panchayat']);
          });
        } else {
          // Handle unexpected district response
          throw Exception('Unexpected district returned from API');
        }
      } else {
        throw Exception('Failed to load gram panchayats');
      }
    } catch (e) {
      print('Error fetching gram panchayats: $e');
      // Handle error (e.g., show an error message or retry)
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          resizeToAvoidBottomInset:
              false, // This ensures the bottom sheet doesn't move when keyboard is shown

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(constraints.maxHeight * 0.18),
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight * 0.18,
              decoration: const ShapeDecoration(
                color: Color(0xFF5C964A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "      Click & Complaints",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'District',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showSheet(
                      "Select District",
                      districts,
                      (district) => setState(() {
                        selectedDistrict = district;
                        fetchGramPanchayats(selectedDistrict!);
                        selectedGP = null;
                      }),
                    ),
                    child: Container(
                      width: constraints.maxWidth * 0.92,
                      height: 52,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFFA4A4A4),
                            size: constraints.maxWidth * 0.05,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedDistrict ?? 'Select District',
                              style: TextStyle(
                                color: selectedDistrict == null
                                    ? const Color(0xFFA4A4A4)
                                    : Colors.black,
                                fontSize: constraints.maxWidth * 0.04,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: Color(0xFFA4A4A4)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gram Panchayat',
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showSheet(
                      "Select Gram Panchayat",
                      gramPanchayats,
                      (gp) => setState(() => selectedGP = gp),
                    ),
                    child: Container(
                      width: constraints.maxWidth * 0.92,
                      height: 52,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_city,
                            color: const Color(0xFFA4A4A4),
                            size: constraints.maxWidth * 0.05,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedGP ?? 'Select Gram Panchayat',
                              style: TextStyle(
                                color: selectedGP == null
                                    ? const Color(0xFFA4A4A4)
                                    : Colors.black,
                                fontSize: constraints.maxWidth * 0.04,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: Color(0xFFA4A4A4)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.04,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 56,
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            color: Colors.white,
                          ),
                          child: TextField(
                            onChanged: (text) {
                              setState(() {
                                caption = text;
                              });
                            },
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.04,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: 'Add a description',
                              hintStyle: TextStyle(
                                color: const Color(0xFFA4A4A4),
                                fontSize: constraints.maxWidth * 0.04,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                              ),
                              prefixIcon: Icon(Icons.description,
                                  color: Colors.grey), // Your icon here
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 20),
                  if (!hasCapturedImage) ...[
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.23,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 50),
                              Container(
                                width: 79.78,
                                height: 79.78,
                                decoration: const BoxDecoration(),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 80,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Click and Complaints',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ] else ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageData.isNotEmpty) ...[
                          const Text(
                            "Preview Photos:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ...imageData.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  var data = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.memory(
                                            Uint8List.fromList(data['image']),
                                            height: screenHeight * 0.2,
                                            width: screenWidth * 0.35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => _deleteImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                if (imageData.length < 3)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: screenWidth * 0.35,
                                        height: screenHeight * 0.2,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo,
                                          color: Colors.grey,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomSheet: Padding(
            padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                    ? Center(
                        child:
                            SweepingBroomLoader()) // Show loader when isLoading is true
                    : Center(
                        // Centering the button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(92, 150, 74, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                          ),
                          onPressed: submitComplaint,
                          child: const Text(
                            "Submit Complaint",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.10,
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
}
