// WokersScreen/WorkerScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../PoweredByBikaji.dart';
import '../Login/workerLogout.dart';
import '../authority/CEO/contractorDetails.dart';
import 'WorkerCommon/ActionScreen.dart';
import 'D2D/D2DSectionScreen.dart';
import 'RRC/RRCSectionScreen.dart';
import 'Wages/WagesActionScreen.dart';
import 'WorkerComplaints/workerComplaintsScreen.dart';
import 'package:intl/intl.dart';
import '../../button_items.dart';

class WorkerScreen extends StatefulWidget {
  @override
  _WorkerScreenState createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {

  @override
  void initState() {
    super.initState();   
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerSettingsPage(),
                          ),
                        );
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
                  Container(
                    height: screenHeight * 0.14, // Adjust the height as needed
                    decoration: BoxDecoration(
                      color: Color(
                          0xFF5C964A), // Change this to your app's primary color
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                16), // Rounded corners for the image
                            child: Image.asset(
                              'assets/images/mainimage.png', // Path to your asset image
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  'Home',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Wrap(
                        spacing: 0, // Horizontal space between buttons
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

                    SizedBox(height: 16),
                    // Scrollable "Home" label and buttons grid
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                    'assets/images/Complaints.png',
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 26),
                    PoweredByBikaji(),
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

      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),

      height: MediaQuery.of(context).size.height *
          0.3, // Adjust height based on screen size
      width: MediaQuery.of(context).size.width *
          0.8, // Adjust width based on screen size
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
        width: MediaQuery.of(context).size.width * 0.4, // Responsive width
        height: MediaQuery.of(context).size.height * 0.15, // Responsive height
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
              width: MediaQuery.of(context).size.width *
                  0.12, // Responsive image width
              height: MediaQuery.of(context).size.width *
                  0.12, // Responsive image height
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
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
      ),
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case 'DoorToDoorScreen':
        return D2DSectionScreen(section: 'Door to Door');
      case 'RoadSweepingScreen':
        return ActionScreen(section: 'Road Sweeping');
      case 'DrainCleaningScreen':
        return ActionScreen(section: 'Drainage Cleaning');
      case 'CSCScreen':
        return ActionScreen(section: 'CSC');
      case 'RRCScreen':
        return RRCScreen(section: 'RRC');
      case 'WagesScreen':
        return WagesActionScreen(section: 'Wages');
      case 'ContractorDetailsScreen':
        return FutureBuilder<String>(
          future: _getGramPanchayat(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text("Error loading data")));
            }
            return Contractordetails(gramPanchayat: snapshot.data ?? '');
          },
        );
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }

  Future<String> _getGramPanchayat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gram_panchayat') ?? '';
  }
}
