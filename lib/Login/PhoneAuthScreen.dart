// Login/PhoneAuthScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthorityLoginScreen.dart';
import 'OTPVerificationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String _countryCode = '+91';

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

  void _sendOTP() async {
    setState(() => _isLoading = true);
    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || !RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      setState(() => _isLoading = false);
      _showError(AppLocalizations.of(context)!.invalid_phone);
      return;
    }

    try {
      await _auth.verifyPhoneNumber(
        timeout: Duration.zero,
        phoneNumber: _countryCode + phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _showError(
              e.message ?? AppLocalizations.of(context)!.verification_failed);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                  verificationId: verificationId, phoneNumber: phoneNumber),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFEFEFEF),
        child: Stack(
          children: [
            Positioned(
              left: screenWidth / 2 - 50,
              top: screenHeight * 0.2,
              child: Text(
                localizations.login,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Positioned(
              left: screenWidth / 2 - 100,
              top: screenHeight * 0.3,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: localizations.enter_mobile_number,
                      style: TextStyle(
                        color: Color.fromARGB(255, 92, 150, 74),
                        fontSize: 20,
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: screenWidth / 2 - 130,
              top: screenHeight * 0.35,
              child: SizedBox(
                width: 260,
                child: Text(
                  localizations.info_not_shared,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: screenHeight * 0.45,
              right: 16,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        _countryCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Nunito Sans',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: localizations.enter_number,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: screenHeight * 0.55,
              right: 16,
              child: _isLoading
                  ? Center(
                      child: Image.asset(
                        'assets/images/Loder.gif',
                        width: 200,
                        height: 200,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _sendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C964A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        localizations.send_otp,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito Sans',
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: screenHeight * 0.65,
              left: screenWidth / 2 - 80,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthorityLoginScreen()),
                  );
                },
                child: Text(
                  localizations.login_admin,
                  style: TextStyle(
                    color: Color(0xFF5C964A),
                    fontSize: 16,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
