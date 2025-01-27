// CitizensScreen/ComplaintsScreen/ComplaintRegisterScreen.dart
import 'package:flutter/material.dart';
import '../CitizensScreen.dart';

class ComplaintRegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFEFEFEF),
        ),
        child: Stack(
          children: [
            // Header section
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.2, // 20% of screen height
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
            Positioned(
              left: 0,
              top: screenHeight * 0.1, // Position adjusted with percentage
              child: Container(
                width: screenWidth,
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
            // Success image section
            Positioned(
              left: 0,
              top: screenHeight * 0.2, // Adjusted to align below the header
              child: Container(
                width: screenWidth,
                height: screenHeight * 0.35, // 35% of screen height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/successScreen.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // Icon below the success image
            Positioned(
              left: screenWidth / 2 - 31,
              top: screenHeight * 0.65, // Adjusted position
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
            // Complaints filed message
            Positioned(
              left: screenWidth / 2 - 122,
              top: screenHeight * 0.75, // Adjusted position
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
            // Bottom sheet
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: screenWidth,
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
            // Back button
            Positioned(
              left: screenWidth / 2 - 40,
              bottom: screenHeight * 0.12, // Adjusted position
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CitizensScreen()),
                  );
                },
                child: Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF5C964A),
                    borderRadius: BorderRadius.circular(20),
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
            ),
          ],
        ),
      ),
    );
  }
}
