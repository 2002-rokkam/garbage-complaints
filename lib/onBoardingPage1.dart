// onBoardingPage1.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'LanguageSelectionScreen.dart';
import 'Login/PhoneAuthScreen.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) changeLanguage;

  OnboardingScreen({super.key, required this.changeLanguage});

  @override
  State<OnboardingScreen> createState() => _Onboard1State();
}

class _Onboard1State extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  String title = "SBMG";
  double fontSize = 28;
  FontWeight fontWeight = FontWeight.w800;
  double truckPosition = -200;

  late AnimationController _controller;
  late Animation<double> _truckAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for truck movement
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {
          truckPosition = _truckAnimation.value;
        });
      });

    // Start the truck animation after 1 second delay
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward();
    });

    // Navigate to next screen after 8 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LanguageSelectionScreen(
                    changeLanguage: widget.changeLanguage,
                  )));
    });

    // Delay the text change and animation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        title = 'Swachhta Bharat Mission Grameen';
        fontSize = 18;
        fontWeight = FontWeight.w600;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _truckAnimation = Tween<double>(
        begin: -200,
        end: screenWidth * 0.372,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    });

    double locationLogoOffsetX = -screenWidth * 0.01;
    double locationLogoOffsetY = -screenHeight * 0.02;
    double truckWidth = screenWidth * 0.32;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5C964A),
                    Color(0xFF3F6633),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset:
                            Offset(locationLogoOffsetX, locationLogoOffsetY),
                        child: Image.asset(
                          'assets/images/LocationLogo.png',
                          height: screenHeight * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                        child: Text(
                          title,
                          key: ValueKey<String>(title),
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'RAJASTHAN',
                      style: TextStyle(
                        fontSize: screenHeight * 0.03, // Responsive font size
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Animated truck movement
          AnimatedPositioned(
            duration: const Duration(
                seconds: 0), // Duration is handled by the controller
            curve: Curves.easeInOut,
            left: truckPosition,
            bottom: screenHeight * 0.505,
            child: Image.asset(
              'assets/images/TruckLogo.png',
              height: truckWidth,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
