// Login/OTPVerificationScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
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
  List<Color> _borderColors = List.generate(6, (index) => Colors.grey);
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

  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
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

      if (idToken != null) {
        final response = await _sendTokenToBackend(idToken);

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CitizensScreen()),
          );
        } else {
          _setBorderColor(Colors.red);
        }
      }
    } catch (e) {
      _setBorderColor(Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setBorderColor(Color color) {
    setState(() {
      _borderColors =
          List.filled(6, color); // ✅ This ensures a new list instance
    });
  }

  Future<http.Response> _sendTokenToBackend(String idToken) async {
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', token);
    } else {
      throw 'Failed to login. Status code: ${response.statusCode}';
    }
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                    localizations.enter_otp,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localizations.otp_sent(widget.phoneNumber),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
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
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _borderColors[
                                        index], // ✅ Updated dynamically
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _borderColors[
                                        index], // ✅ Ensure it updates dynamically
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
                  foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 92, 150, 74),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        localizations.submit_otp,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
