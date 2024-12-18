// ComplaintScreen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComplaintScreen extends StatefulWidget {
  final String phoneNumber;

  const ComplaintScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber;
  }

  String? selectedDistrict;
  String? selectedGP;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> imageData = [];

  Future<void> submitComplaint() async {
    if (selectedDistrict != null &&
        selectedGP != null &&
        imageData.isNotEmpty) {
      try {
        var uri = Uri.parse(
            'https://1745-122-172-84-220.ngrok-free.app/api/complaints-register');

        var request = http.MultipartRequest('POST', uri)
          ..fields['mobile_number'] = _phoneNumber
          ..fields['district'] = selectedDistrict!
          ..fields['gram_panchayat'] = selectedGP!
          ..fields['caption'] = caption;

        // Add photos and geo-coordinates
        for (int i = 0; i < imageData.length; i++) {
          var image = imageData[i]['image'] as Uint8List;
          var latitude = imageData[i]['latitude'].toString();
          var longitude = imageData[i]['longitude'].toString();

          // Add photo as multipart file
          request.files.add(http.MultipartFile.fromBytes(
            'photos',
            image,
            filename: 'photo${i + 1}.jpg',
          ));

          // Add latitude and longitude for each photo
          request.fields['latitude_photo${i + 1}.jpg'] = latitude;
          request.fields['longitude_photo${i + 1}.jpg'] = longitude;
        }

        var response = await request.send();

        if (response.statusCode == 201) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(responseData);

          if (jsonResponse['message'] == 'Complaint registered successfully!') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Complaint Submitted Successfully!")),
            );

            // Clear the form after submission
            setState(() {
              selectedDistrict = null;
              selectedGP = null;
              imageData.clear();
              caption = '';
            });
          }
        } else {
          throw 'Failed to submit complaint. Try again later.';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
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

  bool hasCapturedImage = false; // Track if an image has been captured

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (pickedFile != null) {
        final position = await _determinePosition();
        final imageBytes = await pickedFile.readAsBytes();

        setState(() {
          imageData.add({
            'image': imageBytes,
            'caption': caption, // Assign the common caption
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

  void _showBottomSheet(
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

                  // Search Bar
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

                  // List of Options
                  Expanded(
                    child: ListView.builder(
                      controller:
                          controller, // Attach to DraggableScrollableSheet
                      itemCount: filteredOptions.length,
                      itemBuilder: (_, index) {
                        return ListTile(
                          title: Text(filteredOptions[index]),
                          onTap: () {
                            onSelect(filteredOptions[index]);
                            Navigator.pop(
                                context); // Close the sheet after selection
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
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(screenHeight * 0.18), // Adjust height relative to screen height
      child: Container(
        width: double.infinity,
        height: screenHeight * 0.18,
        decoration: const ShapeDecoration(
          color: Color(0xFF5C964A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        child: Center(
          child: const Text(
            "File Complaint / Feedback",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // Padding adjusted based on screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'File Your Complaint',
              style: TextStyle(
                color: Colors.black,
                fontSize: screenWidth * 0.05, // Adjust font size based on screen width
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0.05,
                letterSpacing: 0.20,
              ),
            ),
            const SizedBox(height: 36),
            // Select District UI
            GestureDetector(
              onTap: () => _showBottomSheet(
                "Select District",
                districts,
                (district) => setState(() {
                  selectedDistrict = district;
                  selectedGP = null; // Reset GP when district changes
                }),
              ),
              child: Container(
                width: screenWidth * 0.92, // Make the container width relative to screen size
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        selectedDistrict ?? 'Select District',
                        style: TextStyle(
                          color: selectedDistrict == null
                              ? Color(0xFFA4A4A4)
                              : Colors.black,
                          fontSize: screenWidth * 0.04, // Adjust font size based on screen width
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

            // Select Gram Panchayat UI
            GestureDetector(
              onTap: () => _showBottomSheet(
                "Select Gram Panchayat",
                districtToGPs[selectedDistrict]!,
                (gp) => setState(() => selectedGP = gp),
              ),
              child: Container(
                width: screenWidth * 0.92, // Make the container width relative to screen size
                height: 52,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        selectedGP ?? 'Select Gram Panchayat',
                        style: TextStyle(
                          color: selectedGP == null
                              ? Color(0xFFA4A4A4)
                              : Colors.black,
                          fontSize: screenWidth * 0.04, // Adjust font size based on screen width
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
            // Caption Input Field
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Container(
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
                  color: Colors.white, // Optional background for better contrast
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (text) {
                          setState(() {
                            caption = text; // Store the caption
                          });
                        },
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Adjust font size based on screen width
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Colors.black, // Adjust for user input
                        ),
                        decoration: InputDecoration(
                          // Add border here
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // You can adjust the radius here
                            borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.0), // Border color and width
                          ),
                          hintText: 'Add a description',
                          hintStyle: TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontSize: screenWidth * 0.04, // Adjust font size
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(
              color: Colors.grey, // Line color
              thickness: 1, // Line thickness
              indent: 10, // Left indent to give spacing
              endIndent: 10, // Right indent to give spacing
            ),
            const SizedBox(height: 20),
            // Image Capture UI
            if (!hasCapturedImage) ...[
              // Display "Click and Capture" in the center initially
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: screenWidth * 0.4, // Adjust container width relative to screen
                    height: screenHeight * 0.23, // Adjust height relative to screen
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start, // Start the alignment for single line text
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Container(
                          width: 59.78,
                          height: 59.78,
                          decoration: const BoxDecoration(),
                          child: const Icon(
                            Icons.camera, // Using camera icon
                            size: 50, // Adjust the size of the icon if needed
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: const Text(
                            'Click and Capture',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 1.25, // Adjust line height
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ] else ...[
              // After capturing an image
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageData.isNotEmpty) ...[
                    const Text(
                      "Preview Photos:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: imageData.map((data) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                Uint8List.fromList(data['image']),
                                height: screenHeight * 0.2, // Set image height relative to screen
                                width: screenWidth * 0.35, // Set image width relative to screen
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList()
                          ..add(
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: screenWidth * 0.3,
                                  height: screenWidth * 0.3,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: Color(0xFF5C964A)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 59.78,
                                          height: 59.78,
                                          decoration: const BoxDecoration(),
                                          child: const FlutterLogo(),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Click and Capture',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    bottomSheet: Padding(
      padding: EdgeInsets.all(screenWidth * 0.05), // Padding relative to screen width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(92, 150, 74, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
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
  );
}
}

final List<String> districts = [
  'Ajmer',
  'Alwar',
  'Banswara',
  'Baran',
  'Barmer',
  'Bharatpur',
  'Bhilwara',
  'Bikaner',
  'Bundi',
  'Chittorgarh',
  'Churu',
  'Dausa',
  'Dholpur',
  'Dungarpur',
  'Hanumangarh',
  'Jaipur',
  'Jaisalmer',
  'Jalore',
  'Jhalawar',
  'Jhunjhunu',
  'Jodhpur',
  'Karauli',
  'Kota',
  'Nagaur',
  'Pali',
  'Pratapgarh',
  'Rajsamand',
  'Sawai Madhopur',
  'Sikar',
  'Sirohi',
  'Sri Ganganagar',
  'Tonk',
  'Udaipur'
];

final Map<String, List<String>> districtToGPs = {
  'Ajmer': [
    'Pisangan',
    'Pushkar',
    'Jawaja',
    'Srinagar',
    'Silora',
    'Tantoti',
    'Mangliyawas',
    'Gegal',
    'Kekri',
    'Roopangarh'
  ],
  'Alwar': [
    'Bhiwadi',
    'Behror',
    'Mundawar',
    'Tijara',
    'Kathumar',
    'Rajgarh',
    'Kotkasim',
    'Thanagazi',
    'Reni',
    'Ramgarh'
  ],
  'Banswara': [
    'Arthuna',
    'Garhi',
    'Kushalgarh',
    'Bagidora',
    'Sajjangarh',
    'Ghatol',
    'Chhoti Sarwan',
    'Khamera',
    'Anandpuri',
    'Peepalkhunt'
  ],
  'Baran': [
    'Atru',
    'Anta',
    'Chhabra',
    'Kishanganj',
    'Mangrol',
    'Shahabad',
    'Bapcha',
    'Saman',
    'Baran',
    'Chhipabarod'
  ],
  'Barmer': [
    'Balotra',
    'Baytu',
    'Chohtan',
    'Gadra Road',
    'Pachpadra',
    'Sheo',
    'Siwana',
    'Sindhari',
    'Ramdevra',
    'Dungri'
  ],
  'Bharatpur': [
    'Bayana',
    'Deeg',
    'Kaman',
    'Nadbai',
    'Rupwas',
    'Weir',
    'Sewar',
    'Kumher',
    'Chiksana',
    'Bhusawar'
  ],
  'Bhilwara': [
    'Mandalgarh',
    'Shahpura',
    'Asind',
    'Mandal',
    'Banera',
    'Bijolia',
    'Kareda',
    'Hurda',
    'Raipur',
    'Jahazpur'
  ],
  'Bikaner': [
    'Lunkaransar',
    'Dungargarh',
    'Kolayat',
    'Nokha',
    'Khajuwala',
    'Chhatargarh',
    'Pugal',
    'Poogal',
    'Sri Dungargarh',
    'Bajju'
  ],
  'Bundi': [
    'Keshoraipatan',
    'Hindoli',
    'Nainwa',
    'Talera',
    'Indergarh',
    'Deikhera',
    'Kapren',
    'Lakhawala',
    'Kalpuriya',
    'Bundi'
  ],
  'Chittorgarh': [
    'Badi Sadri',
    'Nimbahera',
    'Rawatbhata',
    'Kapasan',
    'Begun',
    'Rashmi',
    'Chhoti Sadri',
    'Gangrar',
    'Bhopalsagar',
    'Barisadri'
  ],
  'Churu': [
    'Sardarshahar',
    'Taranagar',
    'Sujangarh',
    'Ratangarh',
    'Rajgarh',
    'Bidasar',
    'Churu',
    'Bhanin',
    'Jasrasar',
    'Dokwa'
  ],
  'Dausa': [
    'Bandikui',
    'Lalsot',
    'Mahwa',
    'Sikrai',
    'Dausa',
    'Ramgarh Pachwara',
    'Baswa',
    'Mandawar',
    'Lawan',
    'Nangal'
  ],
  'Dholpur': [
    'Rajakhera',
    'Saipau',
    'Bari',
    'Baseri',
    'Manpur',
    'Sepau',
    'Jagner',
    'Nihalganj',
    'Dhaulpur',
    'Chandpur'
  ],
  'Dungarpur': [
    'Aspur',
    'Sagwara',
    'Simalwara',
    'Dungarpur',
    'Chikhli',
    'Bichiwara',
    'Galiyakot',
    'Kherwara',
    'Aaspur',
    'Kanba'
  ],
  'Hanumangarh': [
    'Pilibanga',
    'Nohar',
    'Tibi',
    'Rawatsar',
    'Bhadra',
    'Sangaria',
    'Pallu',
    'Chhani Bari',
    'Hanumangarh Town',
    'Bhirani'
  ],
  'Jaipur': [
    'Chomu',
    'Amer',
    'Dudu',
    'Kotputli',
    'Viratnagar',
    'Jhotwara',
    'Sanganer',
    'Bagru',
    'Shahpura',
    'Phulera'
  ],
  'Jaisalmer': [
    'Pokaran',
    'Ramgarh',
    'Sam',
    'Mohanagarh',
    'Kuldhara',
    'Fatehgarh',
    'Bhainsada',
    'Lathi',
    'Dedha',
    'Baramsar'
  ],
  'Jalore': [
    'Bhinmal',
    'Raniwara',
    'Sanchore',
    'Ahore',
    'Jalore',
    'Bagoda',
    'Sayla',
    'Chitalwana',
    'Bagra',
    'Raniwara'
  ],
  'Jhalawar': [
    'Jhalrapatan',
    'Khanpur',
    'Manoharthana',
    'Pirawa',
    'Bhawanimandi',
    'Aklera',
    'Dag',
    'Bakani',
    'Raipur',
    'Suwasana'
  ],
  'Jhunjhunu': [
    'Khetri',
    'Chirawa',
    'Udaipurwati',
    'Pilani',
    'Nawalgarh',
    'Surajgarh',
    'Mandawa',
    'Jhunjhunu',
    'Alsisar',
    'Singhana'
  ],
  'Jodhpur': [
    'Phalodi',
    'Bilara',
    'Osian',
    'Shergarh',
    'Balesar',
    'Mandor',
    'Jodhpur Rural',
    'Luni',
    'Banar',
    'Baori'
  ],
  'Karauli': [
    'Hindaun',
    'Sapotra',
    'Todabhim',
    'Nadbai',
    'Bayana',
    'Karauli',
    'Mandrayal',
    'Mahuwa',
    'Masalpur',
    'Balanagar'
  ],
  'Kota': [
    'Ladpura',
    'Ramganj Mandi',
    'Sangod',
    'Digod',
    'Itawa',
    'Kanwas',
    'Simliya',
    'Chechat',
    'Bapawar',
    'Mandana'
  ],
  'Nagaur': [
    'Makrana',
    'Parbatsar',
    'Didwana',
    'Ladnun',
    'Kuchaman',
    'Merta',
    'Nagaur',
    'Jayal',
    'Degana',
    'Nawa'
  ],
  'Pali': [
    'Bali',
    'Sumerpur',
    'Jaitaran',
    'Desuri',
    'Marwar Junction',
    'Sojat',
    'Rohat',
    'Rani',
    'Raipur',
    'Pali'
  ],
  'Pratapgarh': [
    'Dhariawad',
    'Arnod',
    'Chhoti Sadri',
    'Pratapgarh',
    'Peepalkhunt',
    'Kumbhalgarh',
    'Bagri',
    'Gadi',
    'Sultanpur',
    'Devgarh'
  ],
  'Rajsamand': [
    'Kumbhalgarh',
    'Amet',
    'Railmagra',
    'Deogarh',
    'Rajsamand',
    'Bhupalsagar',
    'Nathdwara',
    'Delwara',
    'Kelwa',
    'Kankroli'
  ],
  'Sawai Madhopur': [
    'Bamanwas',
    'Bonli',
    'Chauth Ka Barwara',
    'Gangapur City',
    'Khandar',
    'Malarna Dungar',
    'Sawai Madhopur',
    'Sundarpura',
    'Goth Bihari',
    'Nindar'
  ],
  'Sikar': [
    'Fatehpur',
    'Losal',
    'Danta Ramgarh',
    'Lachhmangarh',
    'Neem Ka Thana',
    'Sikar',
    'Shrimadhopur',
    'Khandela',
    'Reengus',
    'Choudhary'
  ],
  'Sirohi': [
    'Pindwara',
    'Mount Abu',
    'Sheoganj',
    'Reodar',
    'Abu Road',
    'Swaroopganj',
    'Bagseen',
    'Paladi',
    'Vanvasi',
    'Barloot'
  ],
  'Sri Ganganagar': [
    'Raisinghnagar',
    'Padampur',
    'Sadulshahar',
    'Ganganagar',
    'Karanpur',
    'Kesrisinghpur',
    'Vijaynagar',
    'Anupgarh',
    'Suratgarh',
    'Gharsana'
  ],
  'Tonk': [
    'Malpura',
    'Niwai',
    'Piplu',
    'Uniara',
    'Deoli',
    'Tonk',
    'Peeplu',
    'Todaraisingh',
    'Newai',
    'Banasthali'
  ],
  'Udaipur': [
    'Gogunda',
    'Jhadol',
    'Kherwara',
    'Rishabhdev',
    'Sarada',
    'Salumbar',
    'Bhinder',
    'Mavli',
    'Vallabhnagar',
    'Girwa'
  ]
};
