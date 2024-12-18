// PhoneAuthScreen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'AuthorityLoginScreen.dart';
import 'ComplaintScreen.dart';
import 'OfficeLoginScreen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  bool _isLoading = false;

  // Add the default country code +91
  String _countryCode = '+91';

  void _verifyPhoneNumber() async {
    setState(() => _isLoading = true);
    try {
      // Format the phone number with the country code
      String phoneNumber = _countryCode + _phoneController.text.trim();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToComplaintScreen(phoneNumber); // Pass the phone number
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _verifyOTP() async {
    if (_verificationId.isEmpty || _otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      _navigateToComplaintScreen(_countryCode + _phoneController.text.trim());
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Invalid OTP");
    }
  }

  void _navigateToComplaintScreen(String phoneNumber) {
    // Remove the country code before passing to ComplaintScreen
    String phoneNumberWithoutCountryCode =
        phoneNumber.replaceFirst(_countryCode, '');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ComplaintScreen(phoneNumber: phoneNumberWithoutCountryCode),
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Authentication"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixText:
                    _countryCode, // Display the country code as a prefix
              ),
            ),
            const SizedBox(height: 16),
            if (_verificationId.isNotEmpty)
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "OTP",
                ),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _verificationId.isEmpty
                        ? _verifyPhoneNumber
                        : _verifyOTP,
                    child: Text(
                        _verificationId.isEmpty ? "Send OTP" : "Verify OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
