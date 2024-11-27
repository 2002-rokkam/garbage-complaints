// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:geolocator/geolocator.dart';

// final List<String> districts = ['Jaipur', 'Udaipur', 'Jodhpur', 'Bikaner'];
// final Map<String, List<String>> districtToGPs = {
//   'Jaipur': ['GP1', 'GP2', 'GP3'],
//   'Udaipur': ['GP4', 'GP5'],
//   'Jodhpur': ['GP6', 'GP7'],
//   'Bikaner': ['GP8', 'GP9'],
// };

// class ComplaintScreen extends StatefulWidget {
//   const ComplaintScreen({Key? key}) : super(key: key);

//   @override
//   _ComplaintScreenState createState() => _ComplaintScreenState();
// }

// class _ComplaintScreenState extends State<ComplaintScreen> {
//   String? selectedDistrict;
//   String? selectedGP;
//   final ImagePicker _picker = ImagePicker();
//   final List<Map<String, dynamic>> imageData = [];
//   final List<String> previousComplaints = ['Complaint 1: Unresolved', 'Complaint 2: Resolved'];

//   Future<Position> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw 'Location services are disabled.';
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw 'Location permissions are denied.';
//       }
//     }
//     return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }

//  Future<void> _pickImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         // Await position determination before updating the state
//         final position = await _determinePosition();
//         final imageBytes = await pickedFile.readAsBytes();

//         setState(() {
//           imageData.add({
//             'image': imageBytes, // Uint8List data
//             'caption': '',
//             'latitude': position.latitude,
//             'longitude': position.longitude,
//           });
//         });
//       }
//     } catch (e) {
//       // Handle exceptions gracefully and show an error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: AppBar(title: const Text("File Complaint / Feedback")),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.05),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // District Dropdown
//               DropdownButtonFormField<String>(
//                 value: selectedDistrict,
//                 hint: const Text("Select District"),
//                 onChanged: (district) {
//                   setState(() {
//                     selectedDistrict = district;
//                     selectedGP = null; // Reset Gram Panchayat when district changes
//                   });
//                 },
//                 items: districts.map((district) {
//                   return DropdownMenuItem(value: district, child: Text(district));
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),

//               // Gram Panchayat Dropdown
//               if (selectedDistrict != null)
//                 DropdownButtonFormField<String>(
//                   value: selectedGP,
//                   hint: const Text("Select Gram Panchayat"),
//                   onChanged: (gp) => setState(() => selectedGP = gp),
//                   items: districtToGPs[selectedDistrict]!
//                       .map((gp) => DropdownMenuItem(value: gp, child: Text(gp)))
//                       .toList(),
//                 ),
//               const SizedBox(height: 16),

//               // Take Photo Button
//               ElevatedButton.icon(
//                 onPressed: _pickImage,
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text("Take Geo-Tagged Photo"),
//               ),
//               const SizedBox(height: 16),

//               // Image Previews
//               if (imageData.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Preview Photos:", style: TextStyle(fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     ...imageData.map((data) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: Column(
//                           children: [
//                             Image.memory(Uint8List.fromList(data['image']), height: 200, fit: BoxFit.cover),
//                             TextField(
//                               decoration: const InputDecoration(labelText: "Add a caption"),
//                               onChanged: (caption) {
//                                 setState(() => data['caption'] = caption);
//                               },
//                             ),
//                             const SizedBox(height: 8),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: () {
//                   if (selectedDistrict != null && selectedGP != null && imageData.isNotEmpty) {
//                     String complaintDetails = 'District: $selectedDistrict\n'
//                         'Gram Panchayat: $selectedGP\n'
//                         'Photos & Captions:\n';

//                     for (var data in imageData) {
//                       complaintDetails += 'Caption: ${data['caption']}, '
//                           'Location: (${data['latitude']}, ${data['longitude']})\n';
//                     }

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Complaint Submitted: $complaintDetails")),
//                     );
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Please fill all details.")),
//                     );
//                   }
//                 },
//                 child: const Text("Submit Complaint / Feedback"),
//               ),
//               const SizedBox(height: 16),

//               // Previous Complaints
//               const Text("Previous Complaints:", style: TextStyle(fontWeight: FontWeight.bold)),
//               ...previousComplaints.map((complaint) => ListTile(
//                     title: Text(complaint),
//                     onTap: () => showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: const Text("Complaint Details"),
//                         content: Text("Details for: $complaint"),
//                         actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
//                       ),
//                     ),
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Required for web plugin registration

// Register geolocator_web for web support


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaint App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ComplaintScreen(),
    );
  }
}

// Districts and Gram Panchayats data
final List<String> districts = ['Jaipur', 'Udaipur', 'Jodhpur', 'Bikaner'];
final Map<String, List<String>> districtToGPs = {
  'Jaipur': ['GP1', 'GP2', 'GP3'],
  'Udaipur': ['GP4', 'GP5'],
  'Jodhpur': ['GP6', 'GP7'],
  'Bikaner': ['GP8', 'GP9'],
};

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  String? selectedDistrict;
  String? selectedGP;
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> imageData = [];
  final List<String> previousComplaints = [
    'Complaint 1: Unresolved',
    'Complaint 2: Resolved'
  ];

  // Determine current position with web compatibility
  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Pick image and add geo-tag
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final position = await _determinePosition();
        final imageBytes = await pickedFile.readAsBytes();

        setState(() {
          imageData.add({
            'image': imageBytes,
            'caption': '',
            'latitude': position.latitude,
            'longitude': position.longitude,
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("File Complaint / Feedback")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // District Dropdown
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                hint: const Text("Select District"),
                onChanged: (district) {
                  setState(() {
                    selectedDistrict = district;
                    selectedGP = null; // Reset Gram Panchayat
                  });
                },
                items: districts.map((district) {
                  return DropdownMenuItem(
                      value: district, child: Text(district));
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Gram Panchayat Dropdown
              if (selectedDistrict != null)
                DropdownButtonFormField<String>(
                  value: selectedGP,
                  hint: const Text("Select Gram Panchayat"),
                  onChanged: (gp) => setState(() => selectedGP = gp),
                  items: districtToGPs[selectedDistrict]!
                      .map((gp) => DropdownMenuItem(value: gp, child: Text(gp)))
                      .toList(),
                ),
              const SizedBox(height: 16),

              // Take Photo Button
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Take Geo-Tagged Photo"),
              ),
              const SizedBox(height: 16),

              // Image Previews
              if (imageData.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Preview Photos:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...imageData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Image.memory(Uint8List.fromList(data['image']),
                                height: 200, fit: BoxFit.cover),
                            TextField(
                              decoration: const InputDecoration(
                                  labelText: "Add a caption"),
                              onChanged: (caption) {
                                setState(() => data['caption'] = caption);
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (selectedDistrict != null &&
                      selectedGP != null &&
                      imageData.isNotEmpty) {
                    String complaintDetails = 'District: $selectedDistrict\n'
                        'Gram Panchayat: $selectedGP\n'
                        'Photos & Captions:\n';

                    for (var data in imageData) {
                      complaintDetails += 'Caption: ${data['caption']}, '
                          'Location: (${data['latitude']}, ${data['longitude']})\n';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Complaint Submitted: $complaintDetails")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all details.")),
                    );
                  }
                },
                child: const Text("Submit Complaint / Feedback"),
              ),
              const SizedBox(height: 16),

              // Previous Complaints
              const Text("Previous Complaints:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...previousComplaints.map((complaint) => ListTile(
                    title: Text(complaint),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Complaint Details"),
                        content: Text("Details for: $complaint"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"))
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
