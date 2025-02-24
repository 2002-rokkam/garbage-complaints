// LanguageSelectionScreen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'Login/PhoneAuthScreen.dart';

// class LanguageSelectionScreen extends StatelessWidget {
//   const LanguageSelectionScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context)!;

//     return Scaffold(
//       appBar: AppBar(title: Text(localizations.app_title)),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => PhoneInputScreen()),
//               );
//             },
//             child: const Text("English"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => PhoneInputScreen()),
//               );
//             },
//             child: const Text("हिन्दी"),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login/PhoneAuthScreen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final Function(Locale) changeLanguage;

  const LanguageSelectionScreen({Key? key, required this.changeLanguage})
      : super(key: key);

  Future<void> _setLanguage(Locale locale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);

    changeLanguage(locale); // ✅ This updates the app language

    // Navigate to PhoneInputScreen after setting language
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PhoneInputScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        width: 402,
        height: 874,
        decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
        child: Stack(
          children: [
            Positioned(
              left: 93.11,
              top: 370,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 13),
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
              left: 16,
              top: 452,
              child: LanguageButton(
                text: 'हिन्दी',
                onTap: () => _setLanguage(const Locale('hi'), context),
              ),
            ),
            Positioned(
              left: 16,
              top: 520,
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
        width: 370,
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
