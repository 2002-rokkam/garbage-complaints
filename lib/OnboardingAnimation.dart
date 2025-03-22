// OnboardingAnimation.dart
import 'package:flutter/material.dart';
import 'Login/PhoneAuthScreen.dart';


class OnboardingAnimation extends StatefulWidget {
  final Function(Locale) changeLanguage;

  OnboardingAnimation({super.key, required this.changeLanguage});

  @override
  State<OnboardingAnimation> createState() => _OnboardingAnimationState();
}

class _OnboardingAnimationState extends State<OnboardingAnimation> with TickerProviderStateMixin {
  String title = "SBMG";
  String subtitle = "Rajasthan";
  double fontSize = 30;
  FontWeight fontWeight = FontWeight.w800;

  late AnimationController _controller;
  late Animation<double> _truckAnimation;
  late AnimationController _bottomImageController;
  late Animation<double> _bottomImageAnimation;
  late AnimationController _emblemFadeController;
  late Animation<double> _emblemFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bottomImageController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _emblemFadeController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
    // Start the truck animation after a 1-second delay
    Future.delayed(const Duration(seconds: 1), () {
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
    _bottomImageController.forward();

     Future.delayed(const Duration(milliseconds: 200), () {
        _emblemFadeController.forward();
      });
  });

    });
    

    // Navigate to next screen after 5 seconds
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PhoneInputScreen()),
        //  LanguageSelectionScreen(
        //           changeLanguage: widget.changeLanguage,
        //         )));
      );
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        title = 'स्वच्छ भारत मिशन (ग्रामीण)';
        subtitle = 'राजस्थान';
        fontSize = 26;
        fontWeight = FontWeight.w600;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenWidth = constraints.maxWidth;
      double screenHeight = constraints.maxHeight;

      double referenceLocationLogoHeight = screenHeight * 0.17;
      double referenceTruckLogoWidth = screenWidth * 0.4;

      double logoRatio = referenceLocationLogoHeight / referenceTruckLogoWidth;
      double locationLogoHeight = referenceLocationLogoHeight;
      double truckLogoWidth = referenceTruckLogoWidth;

      double locationLogoLeft = screenWidth * 0.03;
      double locationLogoEnd = locationLogoLeft + locationLogoHeight;
      double truckEndPosition = (locationLogoEnd * logoRatio) - (0.01 * screenWidth);

      _truckAnimation = Tween<double>(
        begin: -screenWidth * 0.6,
        end: truckEndPosition,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _bottomImageAnimation = Tween<double>(
        begin: -screenHeight*0.4, // Start from bottom of the screen
        end: 0, // Final position at the bottom edge of the screen
      ).animate(CurvedAnimation(
        parent: _bottomImageController,
        curve: Curves.easeOut,
      ));

       _emblemFadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _emblemFadeController,
    curve: Curves.easeIn,
  ));

      return Scaffold(
        body: Stack(
          children: [
            // Gradient Background
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location Logo positioned with dynamic sizing
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: locationLogoLeft,
                          top: screenHeight * 0.02,
                        ),
                        child: Image.asset(
                          'assets/images/LocationLogo.png',
                          height: locationLogoHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Animated Heading
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          title,
                          key: ValueKey<String>(title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Animated Subtitle (Rajasthan)
                    SizedBox(
                      height: screenHeight * 0.04,
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          subtitle,
                          key: ValueKey<String>(subtitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _emblemFadeAnimation,
              builder: (context,child){
                return Positioned(
                top: screenHeight * 0.08, // Adjust vertical position
                left: screenWidth * 0.5 - (screenWidth * 0.15), // Center horizontally
                child: Opacity(
                  opacity: _emblemFadeAnimation.value,
                  child: Image.asset(
                    'assets/images/Emblem.png',
                    width: screenWidth * 0.35, // Set appropriate width
                    height: screenHeight * 0.14, // Set appropriate height
                    fit: BoxFit.contain,
                  ),
                ),
              );
              },
               
            ),
            // Animated Truck
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Positioned(
                  left: _truckAnimation.value,
                  bottom: screenHeight * 0.5,
                  child: SizedBox(
                    width: truckLogoWidth,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/TruckLogo.png',
                fit: BoxFit.contain,
              ),
            ),
            AnimatedBuilder(
              animation: _bottomImageAnimation,
              builder: (context,child){
                return Positioned(
              bottom: _bottomImageAnimation.value,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/3.png',
                width: screenWidth,
                fit: BoxFit.cover, // Stretch to fit width and maintain aspect ratio
              ),
              );
              },
              
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
