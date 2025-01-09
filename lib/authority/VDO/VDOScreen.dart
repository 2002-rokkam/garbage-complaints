// authority/VDO/VDOScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'VDOCalendarActivityScreen.dart';
import 'VDOD2DCalnderActivity.dart';
import 'VDORCCCalendarActivityScreen.dart';
import 'VDOWagesCalendarActivityScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'VDOWorkerComplaintsCalender.dart';
import 'fillContractorDetails.dart';

class VDOScreen extends StatefulWidget {
  @override
  _VDOScreenState createState() => _VDOScreenState();
}

class _VDOScreenState extends State<VDOScreen> {
  final PageController _pageController = PageController();

  int totalComplaints = 0;
  int pendingComplaints = 0;
  int resolvedComplaints = 0;

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
    {
      'label': 'Community Service Centre',
      'imageUrl': 'images/CSC.png',
      'route': 'CSCScreen'
    },
    {
      'label': 'Resource Recovery Centre',
      'imageUrl': 'images/RRC.png',
      'route': 'RRCScreen'
    },
    {'label': 'Wages', 'imageUrl': 'images/wages.png', 'route': 'WagesScreen'},
    {
      'label': 'Contractor Details',
      'imageUrl':
          'images/wages.png', // You can use a different image if you prefer
      'route': 'ContractorDetailsScreen'
    },
  ];


  @override
  void initState() {
    super.initState();
    fetchData();
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

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gramPanchayat = prefs.getString('gram_panchayat');
    print(gramPanchayat);
    if (gramPanchayat != null) {
      final response = await http.get(Uri.parse(
              'https://cc33-122-172-85-145.ngrok-free.app/api/complaints-by-gram-panchayat/')
          .replace(queryParameters: {
        'gram_panchayat': gramPanchayat,
      }));

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data');
        setState(() {
          totalComplaints = data['total_complaints'];
          pendingComplaints = data['pending_complaints'];
          resolvedComplaints = data['resolved_complaints'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Gram Panchayat not found in preferences');
    }
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
        backgroundColor: Color.fromRGBO(239, 239, 239, 1),
        body: Column(
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
            // Complaints label
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Action',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VDOWorkerComplaintsCalender(),
                          ),
                        );
                      },
                      child: Container(
                        width: 370,
                        height: 139,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(36.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total Complaints',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    totalComplaints.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: FontWeight.w400,
                                      height: 1.0,
                                      letterSpacing: 0.24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(36.0),
                              child: Container(
                                width: 64,
                                height: 64,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Image.asset(
                                  'images/Complaints.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // Adjusts the spacing
                      children: [
                        GestureDetector(
                          onTap: () {
                            
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Image.asset(
                                      'images/pending.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    pendingComplaints.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18, // Adjust size as needed
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5), // Adjust spacing as needed
                                  Text(
                                    'Pending ',
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
                        ),
                        GestureDetector(
                          onTap: () {
                           
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Image.asset(
                                      'images/resved.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    resolvedComplaints.toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18, // Adjust size as needed
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 5), // Adjust spacing as needed
                                  Text(
                                    'Resolved ',
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
                        ),
                      ],
                    ),
                    // Scrollable "Home" label and buttons grid
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Wrap(
                        spacing: 1, // Horizontal space between buttons
                        runSpacing: 16, // Vertical space between rows
                        children: buttonItems.map((item) {
                          return _buildButton(
                            item['label']!,
                            item['imageUrl']!,
                            item['route']!,
                            context,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        width: 165, // Fixed width for all buttons
        height: 120, // Fixed height for all buttons
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
          mainAxisAlignment:
              MainAxisAlignment.center, 
          crossAxisAlignment:
              CrossAxisAlignment.start, 
          children: [
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
      ),
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case 'DoorToDoorScreen':
        return VDOD2DCalnderActivityScreen(section: 'Door to Door');
      case 'RoadSweepingScreen':
        return VDOCalendarActivityScreen(section: 'Road Sweeping');
      case 'DrainCleaningScreen':
        return VDOCalendarActivityScreen(section: 'Drainage Cleaning');
      case 'CSCScreen':
        return VDOCalendarActivityScreen(section: 'CSC');
      case 'RRCScreen':
        return VDORCCCalendarActivityScreen(section: 'RRC');
      case 'WagesScreen':
        return VDOWagesCalendarActivityScreen(section: 'Wages');
      case 'ContractorDetailsScreen':
        return FillContractorDetailsScreen(); // Add this case
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }

}