import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  // Future<void> _pickImage() async {
  //   try {
  //     final pickedFile =
  //         await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
  //     if (pickedFile != null) {
  //       final position = await _determinePosition();
  //       final imageBytes = await pickedFile.readAsBytes();
  //       final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('complaint_images/$fileName.jpg');

  //       // Upload image to Firebase Storage
  //       final uploadTask = storageRef.putData(imageBytes);
  //       final snapshot = await uploadTask.whenComplete(() => null);
  //       final imageUrl = await snapshot.ref.getDownloadURL();

  //       setState(() {
  //         imageData.add({
  //           'image': imageBytes,
  //           'caption': '',
  //           'latitude': position.latitude,
  //           'longitude': position.longitude,
  //           'url': imageUrl, // Save the download URL
  //         });
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: ${e.toString()}")),
  //     );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("File Complaint / Feedback"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // District Dropdown
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: "Select District",
                      border: InputBorder.none,
                    ),
                    onChanged: (district) {
                      setState(() {
                        selectedDistrict = district;
                        selectedGP = null;
                      });
                    },
                    items: districts.map((district) {
                      return DropdownMenuItem(
                          value: district, child: Text(district));
                    }).toList(),
                  ),
                ),
              ),

              // Gram Panchayat Dropdown
              if (selectedDistrict != null)
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DropdownButtonFormField<String>(
                      value: selectedGP,
                      decoration: const InputDecoration(
                        labelText: "Select Gram Panchayat",
                        border: InputBorder.none,
                      ),
                      onChanged: (gp) => setState(() => selectedGP = gp),
                      items: districtToGPs[selectedDistrict]!
                          .map((gp) =>
                              DropdownMenuItem(value: gp, child: Text(gp)))
                          .toList(),
                    ),
                  ),
                ),

              // Take Photo Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Geo-Tagged Photo"),
                ),
              ),
              const SizedBox(height: 16),

              // Image Previews
              if (imageData.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Preview Photos:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: imageData.map((data) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    Uint8List.fromList(data['image']),
                                    height: 200,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Add a caption",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (caption) {
                                      setState(() => data['caption'] = caption);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

              // Submit Button
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 24),
                  ),
                  onPressed: () async {
                    if (selectedDistrict != null &&
                        selectedGP != null &&
                        imageData.isNotEmpty) {
                      try {
                        // Prepare data to store
                        List<Map<String, dynamic>> photoData =
                            imageData.map((data) {
                          return {
                            'caption': data['caption'],
                            'latitude': data['latitude'],
                            'longitude': data['longitude'],
                          };
                        }).toList();

                        Map<String, dynamic> complaintData = {
                          'district': selectedDistrict,
                          'gram_panchayat': selectedGP,
                          'photos': photoData,
                          'timestamp': FieldValue.serverTimestamp(),
                        };

                        // Add data to Firestore
                        await FirebaseFirestore.instance
                            .collection('complaints')
                            .add(complaintData);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Complaint Submitted Successfully!")),
                        );

                        // Clear the form
                        setState(() {
                          selectedDistrict = null;
                          selectedGP = null;
                          imageData.clear();
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill all details.")),
                      );
                    }
                  },
                  // onPressed: () async {
                  //   if (selectedDistrict != null &&
                  //       selectedGP != null &&
                  //       imageData.isNotEmpty) {
                  //     try {
                  //       List<Map<String, dynamic>> photoData =
                  //           imageData.map((data) {
                  //         return {
                  //           'caption': data['caption'],
                  //           'latitude': data['latitude'],
                  //           'longitude': data['longitude'],
                  //           'url': data['url'], // Include the image URL
                  //         };
                  //       }).toList();

                  //       Map<String, dynamic> complaintData = {
                  //         'district': selectedDistrict,
                  //         'gram_panchayat': selectedGP,
                  //         'photos': photoData,
                  //         'timestamp': FieldValue.serverTimestamp(),
                  //       };

                  //       // Add data to Firestore
                  //       await FirebaseFirestore.instance
                  //           .collection('complaints')
                  //           .add(complaintData);

                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         const SnackBar(
                  //             content:
                  //                 Text("Complaint Submitted Successfully!")),
                  //       );

                  //       // Clear the form
                  //       setState(() {
                  //         selectedDistrict = null;
                  //         selectedGP = null;
                  //         imageData.clear();
                  //       });
                  //     } catch (e) {
                  //       ScaffoldMessenger.of(context).showSnackBar(
                  //         SnackBar(content: Text("Error: ${e.toString()}")),
                  //       );
                  //     }
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(
                  //           content: Text("Please fill all details.")),
                  //     );
                  //   }
                  // },

                  child: const Text(
                    "Submit Complaint / Feedback",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Previous Complaints
              const Text(
                "Previous Complaints:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Divider(color: Colors.deepPurple.shade200, thickness: 1),
              ...previousComplaints.map((complaint) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      title: Text(complaint),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.deepPurple.shade300),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Complaint Details"),
                          content: Text("Details for: $complaint"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ],
                        ),
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
