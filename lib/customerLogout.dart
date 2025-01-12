// customerLogout.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'onBoardingPage1.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Logout',style: TextStyle(color: Colors.white),),backgroundColor: Color(0xFF5C964A),
      leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_ios),color: Colors.white,),),
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
            ]
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
              setState(() {
                isLoggingOut = true;
              });

              // Call the logout function
              await logout(context);

              Navigator.pushAndRemoveUntil(   //Modify this to the page we are going
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
    // Show loading indicator during logout process
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (context) => Center(
        child: CircularProgressIndicator(), // Replace with custom loading indicator if needed
      ),
    );

    try {
      // API call to logout the user
      String logoutUrl = 'https://c035-122-172-86-134.ngrok-free.app/api/logout'; // Replace with your API endpoint

      // Fetch token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token'); // Assume you have saved an auth token

      // Prepare headers for the API request (assuming you need a token for authentication)
      Map<String, String> headers = {
        'Authorization': 'Token ${token}', // Add authorization token if required
        'Content-Type': 'application/json', // Set content type if needed
      };

      // Make the API call to log the user out
      final response = await http.post(Uri.parse(logoutUrl), headers: headers);

      if (response.statusCode == 200) {
       await prefs.clear();
       print("Logout successful");
        // Simulate some delay for the API call to finish (you can adjust or remove this if needed)
        await Future.delayed(Duration(seconds: 1));

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
            (Route<dynamic> route) => false, // Prevent going back
          );
        }
      } else {
        throw Exception('Failed to log out');
      }
    } catch (e) {
      // Handle any errors during the logout process (network issues, etc.)
      if (context.mounted) {
        Navigator.pop(context); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }
}