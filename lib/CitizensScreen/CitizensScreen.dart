// CitizensScreen/CitizensScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../WokersScreen/WorkerComplaints/workerComplaintsScreen.dart';
import '../customerLogout.dart';
import 'ComplaintsScreen/ComplaintScreen.dart';
import 'package:intl/intl.dart';
import 'ComplaintsScreen/complaintsBottomBar.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // for Timer
import 'package:intl/intl.dart'; // for DateFormat

class CitizensScreen extends StatefulWidget {
  @override
  _CitizensScreenState createState() => _CitizensScreenState();
}

class _CitizensScreenState extends State<CitizensScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Map<String, String>> buttonItems = [
    {
      'label': 'Villages Cleaned',
      'imageUrl': 'images/villages_cleaned.png',
      'route': 'DoorToDoorScreen',
      'number': '345'
    },
    {
      'label': 'Swachhta Mitra',
      'imageUrl': 'images/group-discussion 1.png',
      'route': 'RoadSweepingScreen',
      'number': '150'
    },
    {
      'label': 'Homes and Shops Cleaned',
      'imageUrl': 'images/shop.png',
      'route': 'DrainCleaningScreen',
      'number': '200'
    },
    {
      'label': 'Roads Cleaned',
      'imageUrl': 'images/road_sweeping.png',
      'route': 'CSCScreen',
      'number': '120'
    },
    {
      'label': 'Dumping Yard',
      'imageUrl': 'images/Dumping-Yard.png',
      'route': 'RRCScreen',
      'number': '95'
    },
    {
      'label': 'Garbage Dumped',
      'imageUrl': 'images/Garbage_Dumped.png',
      'route': 'WagesScreen',
      'number': '75'
    },
  ];

  @override
  void initState() {
    super.initState();
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
        return SettingsPage();
      default:
        return _buildCitizenScreenContent();
    }
  }

  Widget _buildCitizenScreenContent() {
    // Get screen width for responsive design
    double screenWidth = MediaQuery.of(context).size.width;

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
                      _buildImageContainer('images/test.jpg'),
                      _buildImageContainer('images/garbage_cleaing2.jpeg'),
                      _buildImageContainer('images/garbage_cleaing3.jpeg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Home',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 16 : 18,
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
                        iconSize: screenWidth < 600
                            ? 25
                            : 30.0, // Adjust icon size for small screens
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplaintScreen(),
                            ),
                          );
                        },
                      ),
                      Transform.translate(
                        offset: Offset(0, -8),
                        child: Text(
                          'Click and Complaints',
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 10 : 12,
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
                        fontSize: screenWidth < 600 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // Complaints Container
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: screenWidth < 600 ? 150 : 170,
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
                        width: screenWidth < 600 ? 150 : 170,
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

                SizedBox(height: 26),

                Container(
                  width: 402,
                  height: 147,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 88, vertical: 11),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 102,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 111,
                              height: 63,
                              decoration: BoxDecoration(),
                              child: Image.asset(
                                'images/bikaji.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              width: double.infinity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Powered By',
                                    style: TextStyle(
                                      color: Color(0xFF3B4A5C),
                                      fontSize: 14,
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Bikaji International',
                                    style: TextStyle(
                                      color: Color(0xFF3B4A5C),
                                      fontSize: 16,
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                        ),
                        
                      ),

                    ],
                  ),
                ),
  SizedBox(height: 26),

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
        automaticallyImplyLeading: false,
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
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF5C964A),
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
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildButton(String label, String imageUrl, String routeName,
      String number, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.42, // 42% of screen width for button
      height: 150,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Color(0xFF6B6B6B),
              fontSize: 12,
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
