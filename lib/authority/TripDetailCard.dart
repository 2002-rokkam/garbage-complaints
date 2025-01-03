// authority/TripDetailCard.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
// For JSON encoding

class TripDetailCard extends StatefulWidget {
  @override
  _TripDetailCardState createState() => _TripDetailCardState();
}

class _TripDetailCardState extends State<TripDetailCard> {
  // Controllers for text fields
  final TextEditingController tripsController = TextEditingController();
  final TextEditingController quantityWasteController = TextEditingController();
  final TextEditingController segregatedDegradableController =
      TextEditingController();
  final TextEditingController segregatedNonDegradableController =
      TextEditingController();
  final TextEditingController segregatedPlasticController =
      TextEditingController();

  // Method to retrieve worker ID from shared preferences
  Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
    return workerId;
  }

  Future<void> _handleSubmit() async {
    try {
      // Retrieve worker ID
      final workerId = await getWorkerId();

      // Validate worker ID
      if (workerId == -1) {
        print("Error: worker_id not found in SharedPreferences.");
        return;
      }

      // Parse values from text fields
      final trips = int.tryParse(tripsController.text) ?? 0;
      final quantityWaste =
          double.tryParse(quantityWasteController.text) ?? 0.0;
      final segregatedDegradable =
          double.tryParse(segregatedDegradableController.text) ?? 0.0;
      final segregatedNonDegradable =
          double.tryParse(segregatedNonDegradableController.text) ?? 0.0;
      final segregatedPlastic =
          double.tryParse(segregatedPlasticController.text) ?? 0.0;

      // Create form data
      final formData = FormData.fromMap({
        'worker_id': workerId,
        'section': 'Waste Details',
        'trips': trips,
        'quantity_waste': quantityWaste,
        'segregated_degradable': segregatedDegradable,
        'segregated_non_degradable': segregatedNonDegradable,
        'segregated_plastic': segregatedPlastic,
      });

      // Submit the data using Dio
      final dio = Dio();
      final response = await dio.post(
        'https://8250-122-172-86-111.ngrok-free.app/api/submit-activity',
        data: formData,
      );

      if (response.statusCode == 201) {
        print("Form submitted successfully!");
        print("Response: ${response.data}");
        // Show success dialog
        _showSuccessDialog(context);
      } else {
        print("Error: ${response.statusCode} - ${response.data}");
      }
    } catch (e) {
      print("Error occurred while submitting form: $e");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: screenWidth * 0.9, // 90% of screen width
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.05,
              horizontal: screenWidth * 0.05,
            ),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Image.asset(
                    'images/done.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: screenWidth * 0.8,
                  child: Text(
                    'Successfully updated Trip details !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: screenWidth * 0.06,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the popup
                    _resetFields(); // Reset the fields
                  },
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: ShapeDecoration(
                      color: Color(0x335C964A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF3E6632),
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w600,
                        ),
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

  void _resetFields() {
    tripsController.clear();
    quantityWasteController.clear();
    segregatedDegradableController.clear();
    segregatedNonDegradableController.clear();
    segregatedPlasticController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.85;
    double cardHeight = screenHeight * 0.75;
    double containerWidth = screenWidth * 0.85;
    double textFieldHeight = 56.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailContainer(
              title: 'Trips',
              child: _buildTextField(tripsController),
              containerWidth: containerWidth,
              textFieldHeight: textFieldHeight,
            ),
            SizedBox(height: 16),
            _buildDetailContainer(
              title: 'Quantity of Waste',
              child: _buildTextField(quantityWasteController),
              containerWidth: containerWidth,
              textFieldHeight: textFieldHeight,
            ),
            SizedBox(height: 16),
            _buildDetailContainer(
              title: 'Segregated Degradable Waste',
              child: _buildTextField(segregatedDegradableController),
              containerWidth: containerWidth,
              textFieldHeight: textFieldHeight,
            ),
            SizedBox(height: 16),
            _buildDetailContainer(
              title: 'Segregated Non-Degradable Waste',
              child: _buildTextField(segregatedNonDegradableController),
              containerWidth: containerWidth,
              textFieldHeight: textFieldHeight,
            ),
            SizedBox(height: 16),
            _buildDetailContainer(
              title: 'Segregated Plastic Waste',
              child: _buildTextField(segregatedPlasticController),
              containerWidth: containerWidth,
              textFieldHeight: textFieldHeight,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _handleSubmit,
              child: _buildSubmitButton(containerWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContainer({
    required String title,
    required Widget child,
    required double containerWidth,
    required double textFieldHeight,
  }) {
    return Container(
      width: containerWidth,
      height: textFieldHeight + 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF252525),
              fontSize: 16,
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: textFieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            decoration: ShapeDecoration(
              color: Color(0xFFEFEFEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter value',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
      ),
      style: TextStyle(
        color: Color(0xFF252525),
        fontSize: 16,
        fontFamily: 'Nunito Sans',
        fontWeight: FontWeight.w400,
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSubmitButton(double containerWidth) {
    return Container(
      width: containerWidth,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xFF5C964A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Submit',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w500,
            height: 1.43,
            letterSpacing: 0.10,
          ),
        ),
      ),
    );
  }
}
