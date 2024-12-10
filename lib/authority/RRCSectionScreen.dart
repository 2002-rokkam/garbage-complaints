import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image selection
import 'package:geolocator/geolocator.dart'; // For geo-tagging

class RRCSectionScreen extends StatefulWidget {
  const RRCSectionScreen({super.key});

  @override
  _RRCSectionScreenState createState() => _RRCSectionScreenState();
}

class _RRCSectionScreenState extends State<RRCSectionScreen> {
  final List<Map<String, dynamic>> _beforeImages = [];
  final List<Map<String, dynamic>> _afterImages = [];
  final _formKey = GlobalKey<FormState>();
  String totalTrips = '';
  String totalWaste = '';
  String degradableWaste = '';
  String nonDegradableWaste = '';
  String plasticWaste = '';

  Future<void> _uploadImage(String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final Position position = await _determinePosition();

      final imageData = {
        'path': image.path,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toString(),
      };

      setState(() {
        if (type == 'before') {
          _beforeImages.add(imageData);
        } else if (type == 'after') {
          _afterImages.add(imageData);
        }
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    return await Geolocator.getCurrentPosition();
  }

  void _saveForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data saved successfully!")),
      );
    }
  }

  Widget _buildImageList(List<Map<String, dynamic>> images, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$type Images",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        if (images.isEmpty) const Text("No images uploaded yet."),
        for (var image in images)
          ListTile(
            leading: Image.file(
              File(image['path']),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title:
                Text("Lat: ${image['latitude']}, Long: ${image['longitude']}"),
            subtitle: Text("Time: ${image['timestamp']}"),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RRC Section"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Before and After Image Upload Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _uploadImage("before"),
                  child: const Text("Upload Before"),
                ),
                ElevatedButton(
                  onPressed: () => _uploadImage("after"),
                  child: const Text("Upload After"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Image Lists
            _buildImageList(_beforeImages, "Before"),
            const SizedBox(height: 20),
            _buildImageList(_afterImages, "After"),
            const SizedBox(height: 20),

            // Data Form
            const Text(
              "Daily Data",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    label: "Total number of trips",
                    onSaved: (value) => totalTrips = value ?? '',
                  ),
                  _buildTextField(
                    label: "Total quantity of waste (kg)",
                    onSaved: (value) => totalWaste = value ?? '',
                  ),
                  _buildTextField(
                    label: "Degradable waste (kg)",
                    onSaved: (value) => degradableWaste = value ?? '',
                  ),
                  _buildTextField(
                    label: "Non-degradable waste (kg)",
                    onSaved: (value) => nonDegradableWaste = value ?? '',
                  ),
                  _buildTextField(
                    label: "Plastic waste (kg)",
                    onSaved: (value) => plasticWaste = value ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text("Save Data"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) =>
            value == null || value.isEmpty ? "This field is required" : null,
        onSaved: onSaved,
      ),
    );
  }
}
