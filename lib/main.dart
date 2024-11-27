import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';

import 'ComplaintScreen.dart';


List<Map<String, String>> authorityData = [
  {'username': 'saikiran', 'password': 'saikiran', 'position': 'state_head','state': 'Andhra'},
  {'username': 'rokkam', 'password': 'rokkam', 'position': 'district_head','district':"kurnool"},
  {'username': 'blockhead ', 'password': 'blockhead', 'position': 'block_head','block':"1st block"},
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbage Complaint Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black, fontSize: 16),
          bodyText2: TextStyle(color: Colors.black, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.deepPurple, // Button color
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Garbage Complaint Management"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carousel for images
              CarouselSlider(
                items: [
                  Image.asset('images/download1.jpg', fit: BoxFit.cover),
                  Image.asset('images/download2.jpg', fit: BoxFit.cover),
                  Image.asset('images/images3.jpg', fit: BoxFit.cover),
                ],
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
              const SizedBox(height: 20),

              // Stylish Info Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStylishInfo(
                        icon: Icons.location_city,
                        label: "120 villages",
                        description: "are cleaned daily",
                      ),
                      _buildStylishInfo(
                        icon: Icons.people,
                        label: "350 Swachhta Mitras",
                        description: "are working actively",
                      ),
                      _buildStylishInfo(
                        icon: Icons.home,
                        label: "15,000 homes & shops",
                        description: "garbage is collected from daily",
                      ),
                      _buildStylishInfo(
                        icon: Icons.directions,
                        label: "500 km",
                        description: "of roads are cleaned daily",
                      ),
                      _buildStylishInfo(
                        icon: Icons.delete,
                        label: "25 dumping yards",
                        description: "operate for garbage collection",
                      ),
                      _buildStylishInfo(
                        icon: Icons.scale,
                        label: "15 tons",
                        description: "of garbage dumped daily",
                      ),
                    ],
                  ),
                ),
              ),

             

              const SizedBox(height: 20),

              // Feedback and Login Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    "Complaint",
                    Icons.feedback,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComplaintScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context,
                    "Office Login",
                    Icons.login,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthorityLoginScreen()),
                      );
                    },
                  ),
                ],
              ),

               const SizedBox(height: 20),

              // Helpline and Feedback Section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "State/District Helpline Numbers:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow("State Helpline:", "1800-123-456"),
                      _buildInfoRow("District Helpline:", "1800-654-321"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildStylishInfo({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            radius: 15, // Reduced size
            child: Icon(icon, color: Colors.white, size: 18), // Smaller icon
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10, // Reduced font size
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}







// class ComplaintScreen extends StatefulWidget {
//   const ComplaintScreen({super.key});

//   @override
//   _ComplaintScreenState createState() => _ComplaintScreenState();
// }

// class _ComplaintScreenState extends State<ComplaintScreen> {
//   String? selectedDistrict;
//   String? selectedGP;
//   List<XFile> images = []; // List to store captured images
//   List<String> previousComplaints = [
//     'Complaint 1: Unresolved',
//     'Complaint 2: Resolved',
//   ];

//   final ImagePicker _picker = ImagePicker(); // Image picker instance
//   final List<Map<String, dynamic>> imageData = []; // To store image details, captions, and geo-location

//   @override
//   Widget build(BuildContext context) {
//     // Get screen size using MediaQuery
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(title: const Text("File Complaint / Feedback")),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // District and GP selection
//               Padding(
//                 padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                 child: DropdownButtonFormField<String>(
//                   value: selectedDistrict,
//                   hint: const Text("Select District"),
//                   onChanged: (district) {
//                     setState(() {
//                       selectedDistrict = district;
//                       selectedGP = null; // Reset GP when district changes
//                     });
//                   },
//                   items: ['Jaipur', 'Udaipur', 'Jodhpur', 'Bikaner'].map((district) {
//                     return DropdownMenuItem<String>(
//                       value: district,
//                       child: Text(district),
//                     );
//                   }).toList(),
//                 ),
//               ),
              
//               if (selectedDistrict != null) 
//                 // GP dropdown (Filtered by selected district)
//                 Padding(
//                   padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                   child: DropdownButtonFormField<String>(
//                     value: selectedGP,
//                     hint: const Text("Select Gram Panchayat"),
//                     onChanged: (gp) {
//                       setState(() {
//                         selectedGP = gp;
//                       });
//                     },
//                     items: ['GP1', 'GP2', 'GP3'].map((gp) {
//                       return DropdownMenuItem<String>(
//                         value: gp,
//                         child: Text(gp),
//                       );
//                     }).toList(),
//                   ),
//                 ),

//               // Button to take geo-tagged photos
//               Padding(
//                 padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     // Request location permission before capturing the image
//                     Position position = await _determinePosition();

//                     // Open the camera to take a picture
//                     final pickedFile = await _picker.pickImage(
//                       source: ImageSource.camera, // Use the camera
//                       imageQuality: 80, // Optional: You can adjust image quality
//                     );

//                     if (pickedFile != null) {
//                       setState(() {
//                         imageData.add({
//                           'image': pickedFile,
//                           'caption': '',  // Placeholder for caption
//                           'latitude': position.latitude,
//                           'longitude': position.longitude,
//                         });
//                       });
//                     }
//                   },
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Take Geo-Tagged Photos"),
//                 ),
//               ),

//               // Preview photos with captions (if any)
//               if (imageData.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Preview Photos:"),
//                     const SizedBox(height: 8),
//                     ...imageData.map((data) {
//                       return Padding(
//                         padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                         child: Column(
//                           children: [
//                             Image.file(File(data['image'].path)),
//                             TextField(
//                               decoration: const InputDecoration(
//                                 labelText: "Add a caption",
//                               ),
//                               onChanged: (caption) {
//                                 setState(() {
//                                   data['caption'] = caption;
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),

//               // Submit button
//               Padding(
//                 padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (selectedDistrict != null &&
//                         selectedGP != null &&
//                         imageData.isNotEmpty) {
//                       // Generate the string with selected district, GP, and image captions
//                       String complaintDetails = 'District: $selectedDistrict\n'
//                           'Gram Panchayat: $selectedGP\n'
//                           'Photos & Captions:\n';

//                       for (var data in imageData) {
//                         complaintDetails += 'Caption: ${data['caption']}, '
//                             'Location: (${data['latitude']}, ${data['longitude']})\n';
//                       }

//                       // Display complaint details in the SnackBar
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(complaintDetails),
//                         ),
//                       );
//                     } else {
//                       // Show error message if validation fails
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Please fill all details")),
//                       );
//                     }
//                   },
//                   child: const Text("Submit Complaint / Feedback"),
//                 ),
//               ),

//               // Previous complaints list
//               const Text(
//                 "Previous Complaints:",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               ...previousComplaints.map((complaint) {
//                 return Padding(
//                   padding: EdgeInsets.only(bottom: screenHeight * 0.02),
//                   child: ListTile(
//                     title: Text(complaint),
//                     onTap: () {
//                       // Show complaint details in a dialog
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: const Text("Complaint Details"),
//                             content: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Complaint: $complaint"),
//                                 // Add more details here (like photos, captions, status)
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Method to get the user's current position (latitude and longitude)
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }

//     // Check if we have permission to access location
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied.');
//       }
//     }

//     // Get current position
//     return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }
// }















class AuthorityLoginScreen extends StatefulWidget {
  const AuthorityLoginScreen({super.key});

  @override
  _AuthorityLoginScreenState createState() => _AuthorityLoginScreenState();
}

class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, String>? authority;

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    authority = authorityData.firstWhere(
      (auth) => auth['username'] == username && auth['password'] == password,
      orElse: () => {},
    );

    if (authority!.isNotEmpty) {
      String position = authority!['position'] ?? '';

      if (position == 'state_head') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AuthorityDataScreen(authority!)),
        );
      } else if (position == 'district_head') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AuthorityDataScreen(authority!)),
        );
      } else if (position == 'block_head') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AuthorityDataScreen(authority!)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid username or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authority Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Enter your username and password"),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

class AuthorityDataScreen extends StatefulWidget {
  final Map<String, String> authority;

  const AuthorityDataScreen(this.authority, {super.key});

  @override
  _AuthorityDataScreenState createState() => _AuthorityDataScreenState();
}

class _AuthorityDataScreenState extends State<AuthorityDataScreen> {
  List<dynamic> complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:5500/data.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        filterComplaints(data);
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void filterComplaints(List<dynamic> data) {
    String position = widget.authority['position'] ?? '';
    String? state = widget.authority['state'];
    String? district = widget.authority['district'];
    String? block = widget.authority['block'];

    setState(() {
      if (position == 'state_head') {
        complaints = data.where((c) => c['state'] == state).toList();
      } else if (position == 'district_head') {
        complaints = data
            .where((c) => c['state'] == state && c['district'] == district)
            .toList();
      } else if (position == 'block_head') {
        complaints = data
            .where((c) =>
                c['state'] == state &&
                c['district'] == district &&
                c['block'] == block)
            .toList();
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaints Overview")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row (side by side)
                crossAxisSpacing: 10, // Space between columns
                mainAxisSpacing: 10, // Space between rows
                childAspectRatio: 1, // Square tiles
              ),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Column(
                    children: [
                      Image.network(complaint['image'],
                          height: 100, width: 100),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint['state'] +
                                  " - " +
                                  complaint['district'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(complaint['comments']),
                            const SizedBox(height: 5),
                            Text(
                              complaint['status'],
                              style: TextStyle(
                                color: complaint['status'] == 'resolved'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}





// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Garbage Complaint Management")),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double buttonSize = constraints.maxWidth / 2;

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       width: buttonSize,
//                       height: buttonSize,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const OtpVerificationScreen()),
//                           );
//                         },
//                         child: const Text("Start Complaint"),
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: buttonSize,
//                       height: buttonSize,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const AuthorityLoginScreen()),
//                           );
//                         },
//                         child: const Text("See Complaints (Authority)"),
//                         style: ElevatedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({super.key});

//   @override
//   _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
// }

// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   bool _isOtpVerified = false;

//   Future<void> _verifyOtp() async {
//     setState(() {
//       _isOtpVerified = true;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("OTP verified!")),
//     );

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//           builder: (context) => const ComplaintSubmissionScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Verify OTP")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Enter your phone number for OTP verification'),
//             TextField(
//               controller: _phoneController,
//               decoration: const InputDecoration(
//                 labelText: "Phone Number",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isOtpVerified
//                   ? null
//                   : _verifyOtp, 
//               child: const Text("Verify OTP"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ComplaintSubmissionScreen extends StatefulWidget {
//   const ComplaintSubmissionScreen({super.key});

//   @override
//   _ComplaintSubmissionScreenState createState() =>
//       _ComplaintSubmissionScreenState();
// }

// class _ComplaintSubmissionScreenState extends State<ComplaintSubmissionScreen> {
//   final TextEditingController _commentController = TextEditingController();
//   File? _image;
//   String? _selectedDistrict;
//   String? _selectedBlock;

//   List<String> districts = ['District 1', 'District 2', 'District 3'];
//   List<String> blocks = ['Block 1', 'Block 2', 'Block 3'];

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Submit Complaint")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Capture a photo of the garbage issue'),
//               ElevatedButton(
//                 onPressed: _pickImage,
//                 child: const Text("Capture Photo"),
//               ),
//               if (_image != null) ...[
//                 const SizedBox(height: 10),
//                 Image.file(_image!),
//               ],
//               const SizedBox(height: 20),
//               const Text('Select your District'),
//               DropdownButton<String>(
//                 value: _selectedDistrict,
//                 hint: const Text("Choose District"),
//                 items: districts.map((String district) {
//                   return DropdownMenuItem<String>(
//                     value: district,
//                     child: Text(district),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedDistrict = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//               const Text('Select your Block'),
//               DropdownButton<String>(
//                 value: _selectedBlock,
//                 hint: const Text("Choose Block"),
//                 items: blocks.map((String block) {
//                   return DropdownMenuItem<String>(
//                     value: block,
//                     child: Text(block),
//                   );
//                 }).toList(),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _selectedBlock = newValue;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//               const Text('Add any comments (optional)'),
//               TextField(
//                 controller: _commentController,
//                 decoration: const InputDecoration(
//                   labelText: "Comment",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_selectedDistrict != null && _selectedBlock != null) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Complaint Submitted")),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Please fill all fields")),
//                     );
//                   }
//                 },
//                 child: const Text("Submit Complaint"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


