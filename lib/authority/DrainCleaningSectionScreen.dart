// authority/DrainCleaningSectionScreen.dart
import 'package:flutter/material.dart';

class DrainCleaningSectionScreen extends StatefulWidget {
  const DrainCleaningSectionScreen({super.key});

  @override
  State<DrainCleaningSectionScreen> createState() =>
      _DrainCleaningSectionScreenState();
}

class _DrainCleaningSectionScreenState
    extends State<DrainCleaningSectionScreen> {
  final List<String> _beforeImages = []; // List to store "before" images
  final List<String> _afterImages = []; // List to store "after" images

  bool _isUploadingBefore = false; // Track uploading state for "before"
  bool _isUploadingAfter = false; // Track uploading state for "after"

  void _uploadImage(String type) async {
    setState(() {
      if (type == "before") {
        _isUploadingBefore = true;
      } else if (type == "after") {
        _isUploadingAfter = true;
      }
    });

    // Simulate image upload process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      if (type == "before") {
        _beforeImages.add("geo_tagged_image_${_beforeImages.length + 1}");
        _isUploadingBefore = false;
      } else if (type == "after") {
        _afterImages.add("geo_tagged_image_${_afterImages.length + 1}");
        _isUploadingAfter = false;
      }
    });
  }

  bool get _canUploadAfter =>
      _beforeImages.isNotEmpty && (_afterImages.length < _beforeImages.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drain Cleaning Section"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Upload Geo-tagged Images",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      _isUploadingBefore ? null : () => _uploadImage("before"),
                  child: _isUploadingBefore
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Upload Before"),
                ),
                ElevatedButton(
                  onPressed: (!_canUploadAfter || _isUploadingAfter)
                      ? null
                      : () => _uploadImage("after"),
                  child: _isUploadingAfter
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text("Upload After"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _beforeImages.length,
                itemBuilder: (context, index) {
                  final hasAfter = index < _afterImages.length;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set ${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Before",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(_beforeImages[index]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "After",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      color: hasAfter
                                          ? Colors.grey[200]
                                          : Colors.red[50],
                                      child: Center(
                                        child: hasAfter
                                            ? Text(_afterImages[index])
                                            : const Text("Not Uploaded"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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


