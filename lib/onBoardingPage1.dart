// onBoardingPage1.dart
import 'package:flutter/material.dart';

import 'onBoardingPage2.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 1200),
            pageBuilder: (_, __, ___) => OnboardingScreen2(),
            transitionsBuilder: (_, animation, __, child) {
              final offsetAnimation =
                  Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero)
                      .animate(animation);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5C964A), // Hex color #5C964A
              Color(0xFF3F6633), // Hex color #3F6633
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/LocationLogo.png', // Replace with your asset
                  height: 150, // Adjust as needed
                ),
              ),
              SizedBox(height: 20), // Add spacing
              Text(
                'SBMG',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'RAJASTHAN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
