// Login/workerLogout.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import '../OnboardingAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerSettingsPage extends StatefulWidget {
  const WorkerSettingsPage({super.key});

  @override
  State<WorkerSettingsPage> createState() => _WorkerSettingsPageState();
}

class _WorkerSettingsPageState extends State<WorkerSettingsPage> {
  bool isLoggingOut = false;
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
      appBar: AppBar(
        title: Text(
          localizations.settings, // Localized 'Settings'
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  const url =
                      'https://drive.google.com/file/d/1ixu-1KI-XLGCnW7oxVnY6TcqM7vl52CN/view?usp=sharing';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.ordersCirculars, // Localized 'Orders/Circulars'
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // FAQs Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  const url =
                      'https://docs.google.com/document/d/1yjxBOrK9Rs-o54HqJh2g957sO2xF3AmOkVePmO2Q2AE/edit?usp=sharing';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.faqs, // Localized 'FAQs'
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Title
            SizedBox(height: 20),
            // Wide Logout Button
            Container(
              width: double.infinity, // Makes the button take the full width
              child: ElevatedButton(
                onPressed: () {
                  // Show confirmation dialog when logout button is pressed
                  showLogoutConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  localizations.logout, // Localized 'Logout'
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isLoggingOut) ...[
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/Loder.gif',
                  width: 200,
                  height: 200,
                ),
              ), // Show a loading indicator when logging out
            ],
            SizedBox(height: 20),
            // Privacy Policy Button
            TextButton(
              onPressed: () async {
                const url = 'https://techvysion.com/SBMG/privacypolicy';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Text(
                localizations.privacyPolicy, // Localized 'Privacy Policy'
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void showLogoutConfirmationDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout), // Localized 'Logout'
        content: Text(
            localizations.logoutConfirmation), // Localized confirmation message
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without logging out
            },
            child: Text(localizations.cancel), // Localized 'Cancel'
          ),
          TextButton(
            onPressed: () async {
              // Start the logout process
              setState(() {
                isLoggingOut = true;
              });

              // Call the logout function
              await logout(context);

              // After successful logout, navigate to language selection screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => OnboardingAnimation(
                        changeLanguage: (Locale locale) {})),
                (Route<dynamic> route) => false, // Prevent going back
              );
            },
            child: Text(localizations.logout), // Localized 'Logout'
          ),
        ],
      ),
    );
  }

  // Logout function with API call
  Future<void> logout(BuildContext context) async {
    try {
      // Fetch worker_id from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? workerId = prefs.getString('worker_id');

      if (workerId == null) {
        throw Exception("Worker ID not found in shared preferences.");
      }

      // API URL
      String logoutUrl =
          'https://sbmgrajasthan.com/api/worker-logout'; // Replace with your API endpoint

      // Prepare body and headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      Map<String, dynamic> body = {
        'worker_id': workerId,
      };

      // Make the API call
      final response = await http.post(
        Uri.parse(logoutUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      // Check if the response is successful (200 OK)
      if (response.statusCode == 200) {
        await prefs.clear();
      } else {
        throw Exception('Failed to log out');
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoggingOut = false;
      });
    }
  }
}
