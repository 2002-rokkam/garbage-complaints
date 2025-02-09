// onBoardingPage1.dart
import 'package:flutter/material.dart';
import 'Login/PhoneAuthScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String title = "SBMG";
  double fontSize = 28;
  FontWeight fontWeight = FontWeight.w800;
  double truckPosition = -180;
  double truckWidth = 120;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        title = 'Swachhta Bharat Mission Grameen';
        fontSize = 18;
        fontWeight = FontWeight.w600;
      });
    });

    /*WidgetsBinding.instance.addPostFrameCallback((_){
      double screenWidth=MediaQuery.of(context).size.width;
      setState(() {
        truckPosition=screenWidth/2-truckWidth/2;
      });
    });*/
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        truckPosition = MediaQuery.of(context).size.width / 2 - truckWidth / 2;
      });
    });

    Future.delayed(Duration(seconds: 8),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> PhoneInputScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjusting offsets dynamically based on screen width
    double locationLogoOffsetX = -screenWidth * 0.046; 
    double locationLogoOffsetY = -screenHeight * 0.01; 
    double initialTruckPosition = -truckWidth * 2; 

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
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
                      child: Transform.translate(
                        offset: Offset(locationLogoOffsetX, locationLogoOffsetY),
                        child: Image.asset(
                          'assets/images/LocationLogo.png',
                          height: screenHeight * 0.2, // Responsive height
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Responsive spacing
                    SizedBox(
                      height: screenHeight * 0.05,
                      child: AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
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
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            left: truckPosition == 0 ? initialTruckPosition : truckPosition,
            top: screenHeight * 0.35, // Adjusting truck position dynamically
            child: Image.asset(
              'assets/images/TruckLogo.png',
              height: truckWidth,
            ),
          )
        ],
      ),
    );
  }
}
