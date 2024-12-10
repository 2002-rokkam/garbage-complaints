import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class RoadSweepingScreen extends StatefulWidget {
  const RoadSweepingScreen({super.key});

  @override
  _RoadSweepingScreenState createState() => _RoadSweepingScreenState();
}

class _RoadSweepingScreenState extends State<RoadSweepingScreen> {
  final List<Map<String, dynamic>> _beforeImages = [];
  final List<Map<String, dynamic>> _afterImages = [];
  bool _isUploadingBefore = false;
  bool _isUploadingAfter = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage(String type) async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return; 

    Position position = await _getCurrentLocation();

    // Get current timestamp
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Create a map of the image data
    Map<String, dynamic> imageData = {
      'imagePath': image.path,
      'timestamp': timestamp,
      'latitude': position.latitude,
      'longitude': position.longitude,
    };

    setState(() {
      if (type == "before") {
        _beforeImages.add(imageData);
        _isUploadingBefore = false;
      } else {
        _afterImages.add(imageData);
        _isUploadingAfter = false;
      }
    });
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      throw Exception('Location services are disabled');
    }

    // Check if the location permissions are granted
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  bool _canUploadAfter() {
    // After images can be uploaded if there is at least 1 before image
    return _beforeImages.isNotEmpty;
  }

  // Function to show image preview
  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // No background color
          child: Stack(
            children: [
              Center(
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to delete an image from the list
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
        title: const Text("Road Sweeping Section"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Upload Geo-Tagged Images",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _isUploadingBefore ? null : () => _uploadImage("before"),
                  child: _isUploadingBefore
                      ? const CircularProgressIndicator()
                      : const Text("Upload Before"),
                ),
                ElevatedButton(
                  onPressed: _canUploadAfter() && !_isUploadingAfter
                      ? () => _uploadImage("after")
                      : null,
                  child: _isUploadingAfter
                      ? const CircularProgressIndicator()
                      : const Text("Upload After"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display Before Images
            const Text(
              "Before Images",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _beforeImages.length,
                itemBuilder: (context, index) {
                  final beforeImage = _beforeImages[index];
                  return Dismissible(
                    key: Key(beforeImage['timestamp']),
                    onDismissed: (direction) {
                      _deleteImage("before", index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          _showImagePreview(context, beforeImage['imagePath']),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text("Before: ${beforeImage['timestamp']}"),
                          subtitle: Text(
                            "Lat: ${beforeImage['latitude']}, Long: ${beforeImage['longitude']}",
                          ),
                          leading: Image.asset(beforeImage['imagePath'],
                              width: 50, height: 50),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteImage("before", index);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Display After Images
            const Text(
              "After Images",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _afterImages.length,
                itemBuilder: (context, index) {
                  final afterImage = _afterImages[index];
                  return Dismissible(
                    key: Key(afterImage['timestamp']),
                    onDismissed: (direction) {
                      _deleteImage("after", index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          _showImagePreview(context, afterImage['imagePath']),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text("After: ${afterImage['timestamp']}"),
                          subtitle: Text(
                            "Lat: ${afterImage['latitude']}, Long: ${afterImage['longitude']}",
                          ),
                          leading: Image.asset(afterImage['imagePath'],
                              width: 50, height: 50),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteImage("after", index);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
