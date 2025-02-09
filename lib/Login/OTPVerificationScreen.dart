// Login/OTPVerificationScreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CitizensScreen/CitizensScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<Color> _borderColors = List.generate(6, (index) => Colors.grey);
  bool _isLoading = false;

  // Verify OTP and sign in user
  Future<void> _verifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      _setBorderColor(const Color.fromARGB(255, 201, 15, 2));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use Firebase PhoneAuthProvider for OTP verification
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final response = await _sendTokenToBackend(idToken);
        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CitizensScreen()),
          );
        } else {
          _setBorderColor(const Color.fromARGB(255, 229, 17, 2));
        }
      }
    } catch (e) {
      print("Error during verification: $e");
      _setBorderColor(const Color.fromARGB(255, 229, 17, 2));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<http.Response> _sendTokenToBackend(String idToken) async {
    print(idToken);
    final url = Uri.parse("https://sbmgrajasthan.com/api/customer-login");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['data']['token'];

      // Save the token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', token);

      print('Token saved to SharedPreferences: $token');
    } else {
      throw 'Failed to login. Status code: ${response.statusCode}';
    }
    return response;
  }

  // Update border color for OTP fields
  void _setBorderColor(Color color) {
    setState(() {
      for (int i = 0; i < 6; i++) {
        _borderColors[i] = color;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.27,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Heading
                  Text(
                    'Enter OTP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Instruction
                  Text(
                    'A 6-digit OTP has been sent to ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // OTP Boxes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _borderColors[index], width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 92, 150, 74),
                  onPrimary: Color.fromARGB(255, 92, 150, 74),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "Submit OTP",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}