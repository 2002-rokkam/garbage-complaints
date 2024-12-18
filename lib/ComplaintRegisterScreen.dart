// ComplaintRegisterScreen.dart

import 'package:flutter/material.dart';

import 'main.dart';

class ComplaintRegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFEFEFEF),
        ),
        child: Stack(
          children: [
            // Top Green Header
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 142,
                decoration: BoxDecoration(
                  color: Color(0xFF5C964A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
            // Time and Status Row
            // Complaints Header
            Positioned(
              left: 0,
              top: 52,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Complaints',
                        style: TextStyle(
                          color: Color(0xFFF5EFF7),
                          fontSize: 22,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Complaint Image Placeholder
            Positioned(
              left: 0,
              top: 150,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/successScreen.png'), // Corrected here
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // Flutter Logo Center
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 31,
              top: 528,
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Icon(
                  Icons.verified_rounded,
                  color: Colors.green,
                  size: 80,
                ),
              ),
            ),
            // Complaint Filed Text
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 122,
              top: 634,
              child: SizedBox(
                width: 244,
                child: Text(
                  'Your complaint has been filed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            // Bottom Sheet
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Container(
                    width: 108,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF1D1B20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Back Button
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 40,
              bottom: 80,
              child: GestureDetector(
                onTap: () {
                  // Navigate to the home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen()), // Replace 'HomeScreen()' with your home screen widget
                  );
                },
                child: Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF5C964A),
                    borderRadius:
                        BorderRadius.circular(20), // Added border radius
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
