// customerLogout.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_2/OnboardingAnimation.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Orders/Circulars',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // FAQs Button
            SizedBox(
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'FAQs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Title
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showLogoutConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isLoggingOut) ...[
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/Loder.gif',
                  width: 200,
                  height: 200,
                ),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                const url = 'https://techvysion.com/SBMG/privacypolicy';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open Privacy Policy.')),
                  );
                }
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                isLoggingOut = true;
              });
              await logout(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OnboardingAnimation(changeLanguage: (locale) {})),
                (Route<dynamic> route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: Image.asset(
                'assets/images/Loder.gif',
                width: 200,
                height: 200,
              ),
            ));
    try {
      String logoutUrl = 'https://sbmgrajasthan.com/api/logout';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('id_token');

      Map<String, String> headers = {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

      final response = await http.post(Uri.parse(logoutUrl), headers: headers);

      if (response.statusCode == 200) {
        await prefs.clear();
        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OnboardingAnimation(changeLanguage: (Locale locale) {})),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        throw Exception('Failed to log out');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }
}
