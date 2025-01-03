// WorkerScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'authority/CustomScreen.dart';
import 'authority/D2DSectionScreen.dart';
import 'authority/RRCSectionScreen.dart';
import 'authority/workerComplaintsScreen.dart';

class WorkerScreen extends StatefulWidget {
  @override
  _WorkerScreenState createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> buttonItems = [
    {
      'label': 'Door to Door',
      'imageUrl': 'images/d2d.png',
      'route': 'DoorToDoorScreen'
    },
    {
      'label': 'Road Sweeping',
      'imageUrl': 'images/road_sweeping.png',
      'route': 'RoadSweepingScreen'
    },
    {
      'label': 'Drain Cleaning',
      'imageUrl': 'images/drainage_collectin.png',
      'route': 'DrainCleaningScreen'
    },
    {'label': 'CSC', 'imageUrl': 'images/CSC.png', 'route': 'CSCScreen'},
    {'label': 'RRC', 'imageUrl': 'images/wages.png', 'route': 'RRCScreen'},
    {'label': 'Wages', 'imageUrl': 'images/wages.png', 'route': 'WagesScreen'},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll images
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          int nextPage = _pageController.page!.toInt() + 1;
          _pageController.animateToPage(
            nextPage % 3,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF5C964A),
          flexibleSpace: Container(
            height: 100,
          ),
        ),
        body: SingleChildScrollView(
          // Wrap the body in SingleChildScrollView
          child: Column(
            children: [
              // AppBar extending to the image start
              Container(
                height: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5C964A), // Green
                      Color.fromRGBO(239, 239, 239, 1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 0.5],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 50,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 150,
                        child: PageView(
                          controller: _pageController,
                          children: [
                            _buildImageContainer(
                                'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
                            _buildImageContainer(
                                'https://europe1.discourse-cdn.com/figma/original/3X/7/1/7105e9c010b3d1f0ea893ed5ca3bd58e6cec090e.gif'),
                            _buildImageContainer(
                                'https://gifyard.com/wp-content/uploads/2023/01/girl-laughs.gif'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Dynamic Button Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  shrinkWrap:
                      true, // Ensures the grid only takes necessary space
                  physics:
                      NeverScrollableScrollPhysics(), // Disable scrolling in GridView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: buttonItems.length,
                  itemBuilder: (context, index) {
                    final item = buttonItems[index];
                    return _buildButton(item['label']!, item['imageUrl']!,
                        item['route']!, context);
                  },
                ),
              ),
              // Complaints Container
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          workerComplaintsScreen(), // Add new screen for complaints
                    ),
                  );
                },
                child: Container(
                    width: 370,
                    height: 139,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 4,
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the items horizontally
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center the items vertically
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Image.asset(
                                'images/Complaints.png', // Load from local assets
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                                height: 10), // Space between logo and text
                            Text(
                              'Complaints',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Nunito Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.25,
                                letterSpacing: 0.16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
              SizedBox(height: 16), // Add some padding below the container
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildButton(
      String label, String imageUrl, String routeName, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _getPage(routeName),
          ),
        );
      },
      child: Container(
        width: 120, // Adjusted width
        height: 80, // Adjusted height
        padding: const EdgeInsets.all(12), // Adjusted padding
        margin: const EdgeInsets.symmetric(
            horizontal: 8), // Added margin from left and right
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          // Move label to bottom
          children: [
            Container(
              width: 51,
              height: 62,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Image.asset(
                imageUrl, // Load from local assets
                fit: BoxFit.cover,
              ),
            ),
            // Adjust the label placement here
            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.start, // Center-align the label
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 14, // Smaller font size
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case 'DoorToDoorScreen':
        return D2DSectionScreen(section: 'Door to Door');
      case 'RoadSweepingScreen':
        return ResponsiveScreen(section: 'Road Sweeping');
      case 'DrainCleaningScreen':
        return ResponsiveScreen(section: 'Drainage Cleaning');
      case 'CSCScreen':
        return ResponsiveScreen(section: 'CSC');
      case 'RRCScreen':
        return RRCScreen(section: 'RRC');
      case 'WagesScreen':
        return ResponsiveScreen(section: 'Wages');
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
