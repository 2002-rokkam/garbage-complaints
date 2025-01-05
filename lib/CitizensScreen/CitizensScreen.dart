// CitizensScreen/CitizensScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'ComplaintsScreen/ComplaintScreen.dart';
import '../WokersScreen/WorkerComplaints/workerComplaintsScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'ComplaintsScreen/complaintsBottomBar.dart';

class CitizensScreen extends StatefulWidget {
  @override
  _CitizensScreenState createState() => _CitizensScreenState();
}

class _CitizensScreenState extends State<CitizensScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Map<String, String>> buttonItems = [
    {
      'label': 'Door to Door',
      'imageUrl': 'images/d2d.png',
      'route': 'DoorToDoorScreen',
      'number': '345'
    },
    {
      'label': 'Road Sweeping',
      'imageUrl': 'images/road_sweeping.png',
      'route': 'RoadSweepingScreen',
      'number': '150'
    },
    {
      'label': 'Drain Cleaning',
      'imageUrl': 'images/drainage_collectin.png',
      'route': 'DrainCleaningScreen',
      'number': '200'
    },
    {
      'label': 'Community Service Centre',
      'imageUrl': 'images/CSC.png',
      'route': 'CSCScreen',
      'number': '120'
    },
    {
      'label': 'Resource Recovery Centre',
      'imageUrl': 'images/RRC.png',
      'route': 'RRCScreen',
      'number': '95'
    },
    {
      'label': 'Wages',
      'imageUrl': 'images/wages.png',
      'route': 'WagesScreen',
      'number': '75'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll images
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
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildCitizenScreenContent();
      case 1:
        return complaintsBottomBar();
      case 2:
        return SettingScreen();
      default:
        return _buildCitizenScreenContent();
    }
  }

  Widget _buildCitizenScreenContent() {
    return Column(
      children: [
        // Fixed image slider
        Container(
          height: 180,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF5C964A), // Green
                Color.fromRGBO(239, 239, 239, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 0.5],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 10,
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
        // Row with "Home" label, gap, and green camera icon with label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt,
                            color: Color(0xFF5C964A)), // Green icon
                        iconSize: 30.0, // Set the icon size
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintScreen(),
                            ),
                          );                        },
                      ),
                      Transform.translate(
                        offset: Offset(0,
                            -8), // Adjust this value to move the text upwards
                        child: Text(
                          'Click and Capture',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )

            ],
          ),
        ),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Dynamic Button Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 1,
                    runSpacing: 16,
                    children: buttonItems.map((item) {
                      return _buildButton(
                        item['label']!,
                        item['imageUrl']!,
                        item['route']!,
                        item['number']!,
                        context,
                      );
                    }).toList(),
                  ),
                ),
                // Complaints label
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Complaints',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Complaints Container
               // Complaints and Help line side by side in a Row
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjusts the spacing
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => workerComplaintsScreen(),
          ),
        );
      },
      child: Container(
        width: 170, // Adjust width as needed
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Image.asset(
                'images/Actin.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ' Help line ',
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
      ),
    ),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintScreen(),
          ),
        );
      },
      child: Container(
        width: 170, // Adjust width as needed
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Image.asset(
                'images/Complaints.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
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
      ),
    ),
  ],
),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: const Color(0xFF5C964A),
        flexibleSpace: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      // Navigate to settings or handle settings action here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor:Color.fromRGBO(239, 239, 239, 1),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF5C964A), // Green color for selected item
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
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

  Widget _buildButton(String label, String imageUrl, String routeName,
      String number, BuildContext context) {
    return Container(
      width: 165, // Fixed width for all buttons
      height: 140, // Fixed height for all buttons
      padding: const EdgeInsets.all(8), // Adjust padding
      margin:
          const EdgeInsets.symmetric(horizontal: 8), // Margin between buttons
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
        mainAxisAlignment: MainAxisAlignment.center, // Keep vertically centered
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to the start (left)
        children: [
          // Image size adjusted to fit inside the fixed size
          Container(
            width: 60, // Fixed image width
            height: 60, // Fixed image height
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8), // Adjusted the gap
          Text(
            number, // Dynamic number from buttonItems
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 16, // Adjust font size as needed
              fontWeight: FontWeight.bold,
              letterSpacing: 0.16,
            ),
          ),
          SizedBox(height: 8), // Gap between number and label
          Text(
            label,
            textAlign: TextAlign.start, // Align text to the left
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 12, // Adjust font size as needed
              fontFamily: 'Nunito Sans',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.16,
            ),
          ),
        ],
      ),
    );
  }
}
class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings Screen'),
      ),
    );
  }
}
