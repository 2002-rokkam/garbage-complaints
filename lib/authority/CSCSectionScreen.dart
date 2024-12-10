import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CSCSectionScreen extends StatefulWidget {
  const CSCSectionScreen({super.key});

  @override
  _CSCSectionScreenState createState() => _CSCSectionScreenState();
}

class _CSCSectionScreenState extends State<CSCSectionScreen> {
  final List<File> _beforeImages = [];
  final List<File> _afterImages = [];
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the gallery or camera
  Future<void> _pickImage(String type) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      setState(() {
        if (type == "before") {
          _beforeImages.add(File(pickedFile.path));
        } else {
          _afterImages.add(File(pickedFile.path));
        }
      });
    }
  }

  // Method to display a dialog with an enlarged image
  void _viewImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(imageFile),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display a list of images
  Widget _buildImageList(List<File> images, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        images.isEmpty
            ? const Text("No images uploaded.")
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images
                    .map(
                      (image) => GestureDetector(
                        onTap: () => _viewImage(image),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CSC Section"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Before and After Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage("before"),
                    child: const Text("Upload Before"),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage("after"),
                    child: const Text("Upload After"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Display Before Images
              _buildImageList(_beforeImages, "Before Cleaning Images"),

              // Display After Images
              _buildImageList(_afterImages, "After Cleaning Images"),
            ],
          ),
        ),
      ),
    );
  }
}
