// Login/workerLogout.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package

import '../onBoardingPage1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerSettingsPage extends StatefulWidget {
  const WorkerSettingsPage({super.key});

  @override
  State<WorkerSettingsPage> createState() => _WorkerSettingsPageState();
}

class _WorkerSettingsPageState extends State<WorkerSettingsPage> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Logout',
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
            // Title
            SizedBox(height: 50),
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
              SizedBox(height: 20),
              CircularProgressIndicator(), // Show a loading indicator when logging out
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
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without logging out
            },
            child: Text('Cancel'),
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
                MaterialPageRoute(builder: (context) => OnboardingScreen()),
                (Route<dynamic> route) => false, // Prevent going back
              );
            },
            child: Text('Logout'),
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
          'https://bd0f-122-172-86-18.ngrok-free.app/api/worker-logout'; // Replace with your API endpoint

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
        print("Logout successful!");
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
