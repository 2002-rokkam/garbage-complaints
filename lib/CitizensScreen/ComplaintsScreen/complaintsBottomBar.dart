// CitizensScreen/ComplaintsScreen/complaintsBottomBar.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ComplaintScreen.dart';
import 'ViewComplaintsScreen.dart';

class complaintsBottomBar extends StatefulWidget {
  @override
  _ComplaintsBottomBarState createState() => _ComplaintsBottomBarState();
}

class _ComplaintsBottomBarState extends State<complaintsBottomBar> {
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintScreen()),
                );
              },
              child: Container(
                width: 370,
                height: 56,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/camera-icn.png',
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.fileComplaint,
                      style: TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 16,
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              // Navigate to the "Previous Complaint" screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewComplaintsScreen()),
              );
            },
            child: Container(
              width: 370,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/document.png', // Replace with the correct path of your image
                    width: 16, // Adjust size as needed
                    height: 16, // Adjust size as needed
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizations.previousComplaint,
                    style: TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 16,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
