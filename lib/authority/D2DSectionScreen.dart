import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class D2DSectionScreen extends StatefulWidget {
  const D2DSectionScreen({super.key});

  @override
  State<D2DSectionScreen> createState() => _D2DSectionScreenState();
}

class _D2DSectionScreenState extends State<D2DSectionScreen> {
  List<Map<String, dynamic>> _beforeImages = [];
  List<Map<String, dynamic>> _afterImages = [];
  String _imeiCode = '';
  final Location _location = Location();
  final ImagePicker _picker = ImagePicker();
  bool _isAfterEnabled = false;

  Future<void> _captureImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final LocationData locationData = await _location.getLocation();
        final geoTaggedImage = {
          'image': File(image.path),
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'timestamp': DateTime.now().toString(),
        };

        setState(() {
          if (type == "before") {
            _beforeImages.add(geoTaggedImage);
            _isAfterEnabled =
                true;
          } else {
            _afterImages.add(geoTaggedImage);
          }
        });
      }
    } catch (e) {
      _showError("Error capturing image: $e");
    }
  }

  Future<void> _scanQRCode() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(onScanned: (result) {
          Navigator.pop(context);
          _showInfo("Scanned QR Code: $result");
        }),
      ),
    );
  }

  Future<void> _enterIMEICode() async {
    final TextEditingController imeiController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter IMEI Code"),
        content: TextField(
          controller: imeiController,
          decoration: const InputDecoration(labelText: "IMEI Code"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _imeiCode = imeiController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showImagePreview(Map<String, dynamic> imageData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Image.file(
                  imageData['image'],
                  fit: BoxFit.contain, // Image will be centered
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete image
  void _deleteImage(String type, int index) {
    setState(() {
      if (type == "before") {
        _beforeImages.removeAt(index);
      } else {
        _afterImages.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("D2D Section"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Geo-tagged Images",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _captureImage("before"),
                  child: const Text("Capture Before"),
                ),
                ElevatedButton(
                  onPressed:
                      _isAfterEnabled ? () => _captureImage("after") : null,
                  child: const Text("Capture After"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Before Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._beforeImages.map((data) {
              return Dismissible(
                key: Key(data['timestamp']),
                direction:
                    DismissDirection.endToStart, // Swipe from right to left
                onDismissed: (direction) {
                  _deleteImage("before", _beforeImages.indexOf(data));
                  _showInfo("Image Deleted");
                },
                background: Container(
                  color: Colors.red,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Image.file(
                    data['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                      "Lat: ${data['latitude']}, Long: ${data['longitude']}"),
                  subtitle: Text("Time: ${data['timestamp']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteImage("before", _beforeImages.indexOf(data));
                      _showInfo("Image Deleted");
                    },
                  ),
                  onTap: () => _showImagePreview(data), // Show preview on tap
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            const Text(
              "After Images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._afterImages.map((data) {
              return Dismissible(
                key: Key(data['timestamp']),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteImage("after", _afterImages.indexOf(data));
                  _showInfo("Image Deleted");
                },
                background: Container(
                  color: Colors.red,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Image.file(
                    data['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                      "Lat: ${data['latitude']}, Long: ${data['longitude']}"),
                  subtitle: Text("Time: ${data['timestamp']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteImage("after", _afterImages.indexOf(data));
                      _showInfo("Image Deleted");
                    },
                  ),
                  onTap: () => _showImagePreview(data), // Show preview on tap
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              title: const Text("Scan QR Code"),
              trailing: const Icon(Icons.qr_code_scanner),
              onTap: _scanQRCode,
            ),
            const Divider(),
            ListTile(
              title: const Text("Enter IMEI Code"),
              trailing: const Icon(Icons.gps_fixed),
              onTap: _enterIMEICode,
              subtitle: Text(_imeiCode.isEmpty ? "Not entered" : _imeiCode),
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  final Function(String) onScanned;

  const QRScannerScreen({required this.onScanned, super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          controller.scannedDataStream.listen((scanData) {
            controller.dispose();
            onScanned(scanData.code ?? "No Data");
          });
        },
      ),
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:location/location.dart' as loc;
// import 'package:geocoding/geocoding.dart'
//     as geocoding; // Alias geocoding package
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class D2DSectionScreen extends StatefulWidget {
//   const D2DSectionScreen({super.key});

//   @override
//   State<D2DSectionScreen> createState() => _D2DSectionScreenState();
// }

// class _D2DSectionScreenState extends State<D2DSectionScreen>
//     with TickerProviderStateMixin {
//   TabController? _tabController;
//   List<Map<String, dynamic>> _beforeImages = [];
//   List<Map<String, dynamic>> _afterImages = [];
//   List<Map<String, dynamic>> _scannedDetails = [];
//   String _imeiCode = '';
//   final loc.Location _location = loc.Location(); // Using the alias
//   final ImagePicker _picker = ImagePicker();
//   bool _isAfterEnabled = false; // Flag to track "After" button
//   double _screenHeight = 0;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   // Helper method to capture a geo-tagged image
//   Future<void> _captureImage(String type) async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//       if (image != null) {
//         final loc.LocationData locationData =
//             await _location.getLocation(); // Using alias
//         final geoTaggedImage = {
//           'image': File(image.path),
//           'latitude': locationData.latitude,
//           'longitude': locationData.longitude,
//           'timestamp': DateTime.now().toString(),
//         };

//         setState(() {
//           if (type == "before") {
//             _beforeImages.add(geoTaggedImage);
//             _isAfterEnabled =
//                 true; // Enable "After" button when "Before" is captured
//           } else {
//             _afterImages.add(geoTaggedImage);
//           }
//         });
//       }
//     } catch (e) {
//       _showError("Error capturing image: $e");
//     }
//   }

//   // QR Code Scanner
//   Future<void> _scanQRCode() async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QRScannerScreen(onScanned: (result) async {
//           // Get location details after scanning the QR
//           loc.LocationData locationData =
//               await _location.getLocation(); // Using alias
//           List<geocoding.Placemark> placemarks =
//               await geocoding.placemarkFromCoordinates(locationData.latitude!,
//                   locationData.longitude!); // Using alias
//           geocoding.Placemark place = placemarks[0];

//           final scannedData = {
//             'qrCode': result,
//             'dateTime': DateTime.now().toString(),
//             'latitude': locationData.latitude,
//             'longitude': locationData.longitude,
//             'address': '${place.street}, ${place.locality}, ${place.country}',
//           };

//           setState(() {
//             _scannedDetails.add(scannedData);
//           });

//           Navigator.pop(context);
//         }),
//       ),
//     );
//   }

//   // GPS IMEI Entry
//   Future<void> _enterIMEICode() async {
//     final TextEditingController imeiController = TextEditingController();
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Enter IMEI Code"),
//         content: TextField(
//           controller: imeiController,
//           decoration: const InputDecoration(labelText: "IMEI Code"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 _imeiCode = imeiController.text;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Show error message
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   // Show information message
//   void _showInfo(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   // Image Preview Dialog
//   void _showImagePreview(Map<String, dynamic> imageData) {
//     showDialog(
//       context: context,
//       barrierDismissible: true, // Allows dismissing by tapping outside
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: EdgeInsets.zero,
//           backgroundColor: Colors.transparent, // Remove background color
//           child: Stack(
//             children: [
//               Center(
//                 child: Image.file(
//                   imageData['image'],
//                   fit: BoxFit.contain, // Image will be centered
//                 ),
//               ),
//               Positioned(
//                 top: 10,
//                 right: 10,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Delete image
//   void _deleteImage(String type, int index) {
//     setState(() {
//       if (type == "before") {
//         _beforeImages.removeAt(index);
//       } else {
//         _afterImages.removeAt(index);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     _screenHeight = MediaQuery.of(context).size.height; // Get screen height

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("D2D Section"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: "Before"),
//             Tab(text: "After"),
//           ],
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Tab View with image list
//           TabBarView(
//             controller: _tabController,
//             children: [
//               // Before Tab
//               _buildImageList("before"),
//               // After Tab
//               _buildImageList("after"),
//             ],
//           ),

//           // Scanned QR Details at the bottom 25%
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: _screenHeight * 0.25,
//               color: Colors.white,
//               padding: const EdgeInsets.all(8.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: _scannedDetails.map((data) {
//                     return Card(
//                       child: ListTile(
//                         title: Text('QR Code: ${data['qrCode']}'),
//                         subtitle: Text(
//                             'Lat: ${data['latitude']}, Long: ${data['longitude']}\n'
//                             'Date & Time: ${data['dateTime']}\n'
//                             'Address: ${data['address']}'),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),

//       // Floating Camera Button
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {
//               // Check which tab is selected and capture image for the selected tab
//               if (_tabController?.index == 0) {
//                 _captureImage("before");
//               } else {
//                 _captureImage("after");
//               }
//             },
//             child: const Icon(Icons.camera_alt),
//             heroTag: null,
//           ),
//           const SizedBox(height: 16), // Space between buttons
//           FloatingActionButton(
//             onPressed: _scanQRCode,
//             child: const Icon(Icons.qr_code_scanner),
//             heroTag: null,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageList(String type) {
//     List<Map<String, dynamic>> images =
//         type == "before" ? _beforeImages : _afterImages;
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           ...images.map((data) {
//             return Dismissible(
//               key: Key(data['timestamp']),
//               direction:
//                   DismissDirection.endToStart, // Swipe from right to left
//               onDismissed: (direction) {
//                 _deleteImage(type, images.indexOf(data));
//                 _showInfo("Image Deleted");
//               },
//               background: Container(
//                 color: Colors.red,
//                 child: const Align(
//                   alignment: Alignment.centerRight,
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Icon(Icons.delete, color: Colors.white),
//                   ),
//                 ),
//               ),
//               child: ListTile(
//                 leading: Image.file(
//                   data['image'],
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                 ),
//                 title: Text(
//                     "Lat: ${data['latitude']}, Long: ${data['longitude']}"),
//                 subtitle: Text("Time: ${data['timestamp']}"),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () {
//                     _deleteImage(type, images.indexOf(data));
//                     _showInfo("Image Deleted");
//                   },
//                 ),
//                 onTap: () => _showImagePreview(data), // Show preview on tap
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }

// class QRScannerScreen extends StatelessWidget {
//   final Function(String) onScanned;

//   const QRScannerScreen({required this.onScanned, super.key});

//   @override
//   Widget build(BuildContext context) {
//     final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//     return Scaffold(
//       appBar: AppBar(title: const Text("QR Scanner")),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: (controller) {
//           controller.scannedDataStream.listen((scanData) {
//             controller.dispose();
//             onScanned(scanData.code ?? "No Data");
//           });
//         },
//       ),
//     );
//   }
// }
