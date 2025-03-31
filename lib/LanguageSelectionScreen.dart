// LanguageSelectionScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/PhoneAuthScreen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(Locale) changeLanguage;

  const LanguageSelectionScreen({Key? key, required this.changeLanguage})
      : super(key: key);

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Future<void> _setLanguage(Locale locale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);

    widget.changeLanguage(locale);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PhoneInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
        child: Stack(
          children: [
            Positioned(
              left: -screenWidth * 0.0, // 5% from left
              top: screenHeight * 0.180, // 52% from top
              child: SizedBox(
                child: Image.asset(
                  'assets/images/GreenLogo.png',
                  height: 140,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.22, // Adjust proportionally
              top: screenHeight * 0.42, // Adjust proportionally
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language_sharp,
                    color: Colors.black,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Pick your ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: 'language',
                          style: TextStyle(
                            color: Color(0xFF5C964A),
                            fontSize: 20,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: screenWidth * 0.05, // 5% from left
              top: screenHeight * 0.52, // 52% from top
              child: LanguageButton(
                text: 'हिन्दी',
                onTap: () => _setLanguage(const Locale('hi'), context),
              ),
            ),
            Positioned(
              left: screenWidth * 0.05,
              top: screenHeight * 0.6, // 60% from top
              child: LanguageButton(
                text: 'English',
                onTap: () => _setLanguage(const Locale('en'), context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const LanguageButton({required this.text, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.9, // Adjust width dynamically
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          shadows: [
            const BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
