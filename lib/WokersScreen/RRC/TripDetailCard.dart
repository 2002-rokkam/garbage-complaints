// WokersScreen/RRC/TripDetailCard.dart

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TripDetailCard extends StatefulWidget {
//   @override
//   _TripDetailCardState createState() => _TripDetailCardState();
// }

// class _TripDetailCardState extends State<TripDetailCard> {
//   final TextEditingController tripsController = TextEditingController();
//   final TextEditingController quantityWasteController = TextEditingController();
//   final TextEditingController segregatedDegradableController =
//       TextEditingController();
//   final TextEditingController segregatedNonDegradableController =
//       TextEditingController();
//   final TextEditingController segregatedPlasticController =
//       TextEditingController();

//   bool tripsValid = true;
//   bool quantityWasteValid = true;
//   bool segregatedDegradableValid = true;
//   bool segregatedNonDegradableValid = true;
//   bool segregatedPlasticValid = true;

//   Future<String> getWorkerId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('worker_id') ?? '';
//   }

//   Future<void> _handleSubmit() async {
//     setState(() {
//       tripsValid = tripsController.text.isNotEmpty;
//       quantityWasteValid = quantityWasteController.text.isNotEmpty;
//       segregatedDegradableValid =
//           segregatedDegradableController.text.isNotEmpty;
//       segregatedNonDegradableValid =
//           segregatedNonDegradableController.text.isNotEmpty;
//       segregatedPlasticValid = segregatedPlasticController.text.isNotEmpty;
//     });

//     if (tripsValid &&
//         quantityWasteValid &&
//         segregatedDegradableValid &&
//         segregatedNonDegradableValid &&
//         segregatedPlasticValid) {
//       try {
//         final workerId = await getWorkerId();

//         if (workerId.isEmpty) {
//           print("Error: worker_id not found in SharedPreferences.");
//           return;
//         }

//         final trips = int.tryParse(tripsController.text) ?? 0;
//         final quantityWaste =
//             double.tryParse(quantityWasteController.text) ?? 0.0;
//         final segregatedDegradable =
//             double.tryParse(segregatedDegradableController.text) ?? 0.0;
//         final segregatedNonDegradable =
//             double.tryParse(segregatedNonDegradableController.text) ?? 0.0;
//         final segregatedPlastic =
//             double.tryParse(segregatedPlasticController.text) ?? 0.0;

//         final formData = FormData.fromMap({
//           'worker_id': workerId,
//           'section': 'Waste Details',
//           'trips': trips,
//           'quantity_waste': quantityWaste,
//           'segregated_degradable': segregatedDegradable,
//           'segregated_non_degradable': segregatedNonDegradable,
//           'segregated_plastic': segregatedPlastic,
//         });

//         final dio = Dio();
//         final response = await dio.post(
//           'http://167.71.230.247/api/submit-activity',
//           data: formData,
//         );

//         if (response.statusCode == 201) {
//           _showSuccessDialog(context);
//         } else {
//           print("Error: ${response.statusCode} - ${response.data}");
//         }
//       } catch (e) {
//         print("Error occurred while submitting form: $e");
//       }
//     } else {
//       print("Please fill all fields.");
//     }
//   }

//   void _showSuccessDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;

//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Container(
//             width: screenWidth * 0.9,
//             padding: EdgeInsets.symmetric(
//               vertical: screenHeight * 0.05,
//               horizontal: screenWidth * 0.05,
//             ),
//             decoration: ShapeDecoration(
//               color: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: screenWidth * 0.3,
//                   height: screenWidth * 0.3,
//                   child: Image.asset(
//                     'images/done.png',
//                     width: 24,
//                     height: 24,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.03),
//                 Text(
//                   'Successfully updated Trip details!',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF1D1B20),
//                     fontSize: screenWidth * 0.06,
//                     fontFamily: 'Roboto',
//                     fontWeight: FontWeight.w400,
//                     height: 1.33,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.04),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _resetFields();
//                   },
//                   child: Container(
//                     width: screenWidth * 0.25,
//                     height: screenHeight * 0.05,
//                     decoration: ShapeDecoration(
//                       color: Color(0x335C964A),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Close',
//                         style: TextStyle(
//                           color: Color(0xFF3E6632),
//                           fontSize: screenWidth * 0.035,
//                           fontFamily: 'Nunito Sans',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _resetFields() {
//     tripsController.clear();
//     quantityWasteController.clear();
//     segregatedDegradableController.clear();
//     segregatedNonDegradableController.clear();
//     segregatedPlasticController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     double cardWidth = screenWidth * 0.85;
//     double cardHeight = screenHeight * 0.78;
//     double containerWidth = screenWidth * 0.85;
//     double textFieldHeight = 48.0;

//     return SingleChildScrollView(
//       child: Container(
//         width: cardWidth,
//         height: cardHeight,
//         decoration: ShapeDecoration(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDetailContainer(
//                 title: 'Trips',
//                 child: _buildTextField(tripsController),
//                 containerWidth: containerWidth,
//                 textFieldHeight: textFieldHeight,
//                 isValid: tripsValid,
//               ),
//               SizedBox(height: 16),
//               _buildDetailContainer(
//                 title: 'Quantity of Waste',
//                 child: _buildTextField(quantityWasteController),
//                 containerWidth: containerWidth,
//                 textFieldHeight: textFieldHeight,
//                 isValid: quantityWasteValid,
//               ),
//               SizedBox(height: 16),
//               _buildDetailContainer(
//                 title: 'Segregated Degradable Waste',
//                 child: _buildTextField(segregatedDegradableController),
//                 containerWidth: containerWidth,
//                 textFieldHeight: textFieldHeight,
//                 isValid: segregatedDegradableValid,
//               ),
//               SizedBox(height: 16),
//               _buildDetailContainer(
//                 title: 'Segregated Non-Degradable Waste',
//                 child: _buildTextField(segregatedNonDegradableController),
//                 containerWidth: containerWidth,
//                 textFieldHeight: textFieldHeight,
//                 isValid: segregatedNonDegradableValid,
//               ),
//               SizedBox(height: 16),
//               _buildDetailContainer(
//                 title: 'Segregated Plastic Waste',
//                 child: _buildTextField(segregatedPlasticController),
//                 containerWidth: containerWidth,
//                 textFieldHeight: textFieldHeight,
//                 isValid: segregatedPlasticValid,
//               ),
//               SizedBox(height: 16),
//               GestureDetector(
//                 onTap: _handleSubmit,
//                 child: _buildSubmitButton(containerWidth),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailContainer({
//     required String title,
//     required Widget child,
//     required double containerWidth,
//     required double textFieldHeight,
//     required bool isValid,
//   }) {
//     return Container(
//       width: containerWidth,
//       height: textFieldHeight + 45,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               color: Color(0xFF252525),
//               fontSize: 16,
//               fontFamily: 'Nunito Sans',
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//           SizedBox(height: 8),
//           Container(
//             width: double.infinity,
//             height: textFieldHeight,
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
//             decoration: ShapeDecoration(
//               color: Color(0xFFEFEFEF),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: child,
//           ),
//           SizedBox(height: 5),
//           if (!isValid)
//             Text(
//               'This field is required',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 8,
//                 fontFamily: 'Nunito Sans',
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: 'Enter value',
//         border: InputBorder.none,
//         contentPadding: EdgeInsets.symmetric(horizontal: 0),
//       ),
//       style: TextStyle(
//         color: Color(0xFF252525),
//         fontSize: 16,
//         fontFamily: 'Nunito Sans',
//         fontWeight: FontWeight.w400,
//       ),
//       keyboardType: TextInputType.number,
//     );
//   }

//   Widget _buildSubmitButton(double containerWidth) {
//     return Container(
//       width: containerWidth,
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//       decoration: BoxDecoration(
//         color: Color(0xFF5C964A),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: Text(
//           'Submit',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//             fontFamily: 'Nunito Sans',
//             fontWeight: FontWeight.w500,
//             height: 1.43,
//             letterSpacing: 0.10,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripDetailCard extends StatefulWidget {
  @override
  _TripDetailCardState createState() => _TripDetailCardState();
}

class _TripDetailCardState extends State<TripDetailCard> {
  final TextEditingController tripsController = TextEditingController();
  final TextEditingController quantityWasteController = TextEditingController();
  final TextEditingController segregatedDegradableController =
      TextEditingController();
  final TextEditingController segregatedNonDegradableController =
      TextEditingController();
  final TextEditingController segregatedPlasticController =
      TextEditingController();

  bool tripsValid = true;
  bool quantityWasteValid = true;
  bool segregatedDegradableValid = true;
  bool segregatedNonDegradableValid = true;
  bool segregatedPlasticValid = true;
  bool isLoading = false;

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? '';
  }

  Future<void> _handleSubmit() async {
    setState(() {
      tripsValid = tripsController.text.isNotEmpty;
      quantityWasteValid = quantityWasteController.text.isNotEmpty;
      segregatedDegradableValid =
          segregatedDegradableController.text.isNotEmpty;
      segregatedNonDegradableValid =
          segregatedNonDegradableController.text.isNotEmpty;
      segregatedPlasticValid = segregatedPlasticController.text.isNotEmpty;
      isLoading = true; // Start loading
    });

    if (tripsValid &&
        quantityWasteValid &&
        segregatedDegradableValid &&
        segregatedNonDegradableValid &&
        segregatedPlasticValid) {
      try {
        final workerId = await getWorkerId();

        if (workerId.isEmpty) {
          print("Error: worker_id not found in SharedPreferences.");
          setState(() {
            isLoading = false;
          });
          return;
        }

        final trips = int.tryParse(tripsController.text) ?? 0;
        final quantityWaste =
            double.tryParse(quantityWasteController.text) ?? 0.0;
        final segregatedDegradable =
            double.tryParse(segregatedDegradableController.text) ?? 0.0;
        final segregatedNonDegradable =
            double.tryParse(segregatedNonDegradableController.text) ?? 0.0;
        final segregatedPlastic =
            double.tryParse(segregatedPlasticController.text) ?? 0.0;

        final formData = FormData.fromMap({
          'worker_id': workerId,
          'section': 'Waste Details',
          'trips': trips,
          'quantity_waste': quantityWaste,
          'segregated_degradable': segregatedDegradable,
          'segregated_non_degradable': segregatedNonDegradable,
          'segregated_plastic': segregatedPlastic,
        });

        final dio = Dio();
        final response = await dio.post(
          'http://167.71.230.247/api/submit-activity',
          data: formData,
        );

        if (response.statusCode == 201) {
          _showSuccessDialog(context);
        } else {
          print("Error: ${response.statusCode} - ${response.data}");
        }
      } catch (e) {
        print("Error occurred while submitting form: $e");
      } finally {
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading even if validation fails
      });
      print("Please fill all fields.");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: screenWidth * 0.9,
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
                  child: Image.asset(
                    'images/done.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  'Successfully updated Trip details!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontSize: screenWidth * 0.06,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _resetFields();
                  },
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.05,
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
    double cardHeight = screenHeight * 0.78;
    double containerWidth = screenWidth * 0.85;
    double textFieldHeight = 48.0;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
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
                    isValid: tripsValid,
                  ),
                  SizedBox(height: 16),
                  _buildDetailContainer(
                    title: 'Quantity of Waste',
                    child: _buildTextField(quantityWasteController),
                    containerWidth: containerWidth,
                    textFieldHeight: textFieldHeight,
                    isValid: quantityWasteValid,
                  ),
                  SizedBox(height: 16),
                  _buildDetailContainer(
                    title: 'Segregated Degradable Waste',
                    child: _buildTextField(segregatedDegradableController),
                    containerWidth: containerWidth,
                    textFieldHeight: textFieldHeight,
                    isValid: segregatedDegradableValid,
                  ),
                  SizedBox(height: 16),
                  _buildDetailContainer(
                    title: 'Segregated Non-Degradable Waste',
                    child: _buildTextField(segregatedNonDegradableController),
                    containerWidth: containerWidth,
                    textFieldHeight: textFieldHeight,
                    isValid: segregatedNonDegradableValid,
                  ),
                  SizedBox(height: 16),
                  _buildDetailContainer(
                    title: 'Segregated Plastic Waste',
                    child: _buildTextField(segregatedPlasticController),
                    containerWidth: containerWidth,
                    textFieldHeight: textFieldHeight,
                    isValid: segregatedPlasticValid,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _handleSubmit,
                    child: _buildSubmitButton(containerWidth),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildDetailContainer({
    required String title,
    required Widget child,
    required double containerWidth,
    required double textFieldHeight,
    required bool isValid,
  }) {
    return Container(
      width: containerWidth,
      height: textFieldHeight + 45,
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
          SizedBox(height: 5),
          if (!isValid)
            Text(
              'This field is required',
              style: TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
              ),
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
            color: Colors.white,
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
