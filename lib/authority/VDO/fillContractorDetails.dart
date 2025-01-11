// authority/VDO/fillContractorDetails.dart
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class FillContractorDetailsScreen extends StatefulWidget {
//   @override
//   _ContractorDetailsScreenState createState() =>
//       _ContractorDetailsScreenState();
// }

// class _ContractorDetailsScreenState extends State<FillContractorDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _gstNoController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _contactNoController = TextEditingController();

//   bool _isSubmitting = false;

//   Future<void> _submitDetails() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isSubmitting = true;
//       });

//       try {
//         // Retrieve worker_id from shared preferences
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         final String? workerId = prefs.getString('worker_id');

//         if (workerId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Worker ID not found in preferences'),
//             ),
//           );
//           setState(() {
//             _isSubmitting = false;
//           });
//           return;
//         }

//         final url = Uri.parse(
//             'https://c035-122-172-86-134.ngrok-free.app/api/contractor/create/$workerId');

//         // Prepare the payload
//         final payload = {
//           'company_name': _companyNameController.text,
//           'gst_no': _gstNoController.text,
//           'email': _emailController.text,
//           'contact_no': _contactNoController.text,
//         };

//         // Send POST request
//         final response = await http.post(
//           url,
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(payload),
//         );

//         setState(() {
//           _isSubmitting = false;
//         });

//         if (response.statusCode == 200) {
//           // Success
//           _showSuccessDialog();
//         } else {
//           _showFailureDialog();
//           // Handle non-200 status codes
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to submit details: ${response.statusCode}'),
//             ),
//           );
//         }
//       } catch (error) {
//         setState(() {
//           _isSubmitting = false;
//         });

//         // Handle exceptions
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('An error occurred: $error'),
//           ),
//         );
//       }
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Success Icon
//               CircleAvatar(
//                 radius: 40.0,
//                 backgroundColor: Colors.green.shade100,
//                 child: const Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 60.0,
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               // Title
//               const Text(
//                 'Success!',
//                 style: TextStyle(
//                   fontSize: 22.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//               const SizedBox(height: 10.0),
//               // Content
//               const Text(
//                 'Contractor details have been submitted successfully.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               // OK Button
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context); // Close the dialog
//                   Navigator.pop(context); // Go back to the previous page
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30.0,
//                     vertical: 10.0,
//                   ),
//                 ),
//                 child: const Text(
//                   'OK',
//                   style: TextStyle(fontSize: 16.0, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFailureDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.0),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(20.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Failure Icon
//               CircleAvatar(
//                 radius: 40.0,
//                 backgroundColor: Colors.red.shade100,
//                 child: const Icon(
//                   Icons.error_outline,
//                   color: Colors.red,
//                   size: 60.0,
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               // Title
//               const Text(
//                 'Oops!',
//                 style: TextStyle(
//                   fontSize: 22.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//               const SizedBox(height: 10.0),
//               // Content
//               const Text(
//                 'Failed to submit contractor details. Please try again later.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16.0,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20.0),
//               // Retry Button
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context); // Close the dialog
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 30.0,
//                     vertical: 10.0,
//                   ),
//                 ),
//                 child: const Text(
//                   'Try Again',
//                   style: TextStyle(fontSize: 16.0, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Contractor Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF5C964A),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_ios),
//           color: Colors.white,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 _buildTextField(
//                   controller: _companyNameController,
//                   label: 'Company Name',
//                   hint: 'Company name',
//                   icon: Icons.business,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Please enter company name' : null,
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildTextField(
//                   controller: _gstNoController,
//                   label: 'GST No',
//                   hint: 'GST Info',
//                   icon: Icons.info_outline,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Please enter GST number' : null,
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildTextField(
//                   controller: _emailController,
//                   label: 'Email Address',
//                   hint: 'Email Address',
//                   icon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter email address';
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'Please enter a valid email address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16.0),
//                 _buildTextField(
//                   controller: _contactNoController,
//                   label: 'Contact No',
//                   hint: 'Number',
//                   icon: Icons.phone,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) =>
//                       value!.isEmpty ? 'Please enter contact number' : null,
//                 ),
//                 const SizedBox(height: 32.0),
//                 ElevatedButton(
//                   onPressed: _isSubmitting ? null : _submitDetails,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: _isSubmitting
//                       ? const CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         )
//                       : const Text('Save'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16.0,
//             color: Color.fromARGB(255, 69, 69, 69),
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey),
//             prefixIcon: Icon(
//               icon,
//               color: Colors.grey,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FillContractorDetailsScreen extends StatefulWidget {
  @override
  _ContractorDetailsScreenState createState() =>
      _ContractorDetailsScreenState();
}

class _ContractorDetailsScreenState extends State<FillContractorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? workerId = prefs.getString('worker_id');

        if (workerId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Worker ID not found in preferences'),
            ),
          );
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        final url = Uri.parse(
            'https://c035-122-172-86-134.ngrok-free.app/api/contractor/create/$workerId');

        final payload = {
          'company_name': _companyNameController.text,
          'gst_no': _gstNoController.text,
          'email': _emailController.text,
          'contact_no': _contactNoController.text,
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200) {
          _showSuccessDialog();
        } else {
          _showFailureDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit details: ${response.statusCode}'),
            ),
          );
        }
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60.0,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Contractor details have been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.red.shade100,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60.0,
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Failed to submit contractor details. Please try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contractor Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF5C964A),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _companyNameController,
                  label: 'Company Name',
                  hint: 'Company name',
                  icon: Icons.business,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter company name' : null,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _gstNoController,
                  label: 'GST No',
                  hint: 'GST Info',
                  icon: Icons.info_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter GST number';
                    }
                    if (value.length != 15) {
                      return 'GST number must be 15 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _contactNoController,
                  label: 'Contact No',
                  hint: 'Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    if (value.length != 10) {
                      return 'Contact number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            color: Color.fromARGB(255, 69, 69, 69),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(
              icon,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
