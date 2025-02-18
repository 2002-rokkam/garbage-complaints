// Login/OTPVerificationScreen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CitizensScreen/CitizensScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

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
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<Color> _borderColors = List.generate(6, (index) => Colors.grey);
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();

    // Check if OTP has 6 digits
    if (otp.length != 6 || otp.contains(RegExp(r'[^0-9]'))) {
      _setBorderColor(Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken(true);
      print(idToken);

      if (idToken != null) {
        final response = await _sendTokenToBackend(idToken);
        print("Response Code: ${response.statusCode}");
          print("Response:${response.body}");
        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CitizensScreen()),
          );
        } else {
          _setBorderColor(Colors.red);
         print("err Code: ${response.statusCode}");

        }
      }
    } catch (e) {
      print("Error during verification: $e");
      _setBorderColor(Colors.red);
         
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setBorderColor(Color color) {
    setState(() {
      for (int i = 0; i < 6; i++) {
        if (_controllers[i].text.isEmpty ||
            _controllers[i].text.contains(RegExp(r'[^0-9]'))) {
          _borderColors[i] = color;
        } else {
          _borderColors[i] = Colors.grey;
        }
      }
    });
  }

  Future<http.Response> _sendTokenToBackend(String idToken) async {
    print("step1");
    final url = Uri.parse("https://sbmgrajasthan.com/api/customer-login");
        print("step1");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
    );
     print("Authorization Bearer $idToken");
    print(idToken);
    print("Response Code: ${response.statusCode}");
      print("Response:${response.body}");
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['data']['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', token);
      print(token);
    } else {
      throw 'Failed to login. Status code: ${response.statusCode}';
          print("err Code: ${response.statusCode}");

    }
    return response;
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
                  Text(
                    'Enter OTP',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A 6-digit OTP has been sent to ${widget.phoneNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // OTP Input Fields with Auto-Backspace Handling
                  RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        for (int i = 1; i < 6; i++) {
                          if (_controllers[i].text.isEmpty &&
                              _controllers[i - 1].text.isNotEmpty) {
                            _focusNodes[i - 1].requestFocus();
                            break;
                          }
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 50,
                            height: 50,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _borderColors[index],
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  _controllers[index].text =
                                      value.substring(value.length - 1);
                                  if (index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              },
                              onTap: () {
                                _controllers[index].selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: _controllers[index].text.length),
                                );
                              },
                            ),
                          );
                        }),
                      ),
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
                  onPrimary: Colors.white,
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
