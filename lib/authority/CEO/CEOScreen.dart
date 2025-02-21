// authority/CEO/CEOScreen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../PoweredByBikaji.dart';
import '../../Login/workerLogout.dart';
import '../BDO/BDOWorkerComplaintsCalender.dart';
import '../BDO/BDOWages/BDOWagesCalendarActivityScreen.dart';
import 'CEOCalender/CEOCalendarActivityScreen.dart';
import 'CEOD2D/CEOD2DCalnderActivity.dart';
import 'CEORCC/CEORCCCalendarActivityScreen.dart';
import 'contractorDetails.dart';
import 'CEOselectRegion.dart';
import '../../button_items.dart';

class CEOScreen extends StatefulWidget {
  @override
  _CEOScreenState createState() => _CEOScreenState();
}

class _CEOScreenState extends State<CEOScreen> {
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int resolvedComplaints = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? District = prefs.getString('District');
    print(District);
    if (District != null) {
      final response = await http.get(
          Uri.parse('https://sbmgrajasthan.com/api/complaints-by-district/')
              .replace(queryParameters: {
        'district': District,
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
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
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
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              height: 400, // Adjust height as needed
                              padding: EdgeInsets.all(16.0),
                              child:
                                  CEOselectRegion(), // Show your region selection screen inside the popup
                            ),
                          ),
                        );
                      },
                      child: Padding(
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
                            builder: (context) => BDOWorkerComplaintsCalender(),
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
                                  'assets/images/Complaints.png',
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
                          MainAxisAlignment.spaceEvenly, 
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 170,
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
                                      'assets/images/pending.png',
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
                          onTap: () {},
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
                                      'assets/images/resved.png',
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
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Wrap(
                        spacing: 1, // Horizontal space between buttons
                        runSpacing: 12, // Vertical space between rows
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

  void _navigateToPage(String routeName, BuildContext context) async {
    Widget page = await _getPage(routeName, context);

    if (page is! Scaffold) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  Widget _buildButton(
      String label, String imageUrl, String routeName, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPage(routeName, context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.15,
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
              width: MediaQuery.of(context).size.width * 0.12,
              height: MediaQuery.of(context).size.width * 0.12,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Image.asset(imageUrl, fit: BoxFit.cover),
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

  Future<Widget> _getPage(String routeName, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? appbarselectedDistrict = prefs.getString('appbarselectedDistrict');
    String? appbarselectedBlock = prefs.getString('appbarselectedBlock');
    String? appbarselectedGramPanchayat =
        prefs.getString('appbarselectedGramPanchayat');

    // Check if any of the values are empty or null
    if (appbarselectedDistrict == null ||
        appbarselectedDistrict.isEmpty ||
        appbarselectedBlock == null ||
        appbarselectedBlock.isEmpty ||
        appbarselectedGramPanchayat == null ||
        appbarselectedGramPanchayat.isEmpty) {
      // Show the region selection dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 400, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: CEOselectRegion(),
          ),
        ),
      );
      return Scaffold(); // Return an empty scaffold to prevent navigation
    }

    switch (routeName) {
      case 'DoorToDoorScreen':
        return CEOD2DCalnderActivityScreen(
          section: 'Door to Door',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'RoadSweepingScreen':
        return CEOCalendarActivityScreen(
          section: 'Road Sweeping',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'DrainCleaningScreen':
        return CEOCalendarActivityScreen(
          section: 'Drainage Cleaning',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'CSCScreen':
        return CEOCalendarActivityScreen(
          section: 'CSC',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'RRCScreen':
        return CEORCCCalendarActivityScreen(
          section: 'RRC',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'WagesScreen':
        return BDOWagesCalendarActivityScreen(
          section: 'Wages',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'ContractorDetailsScreen':
        return Contractordetails(
          gramPanchayat: appbarselectedGramPanchayat,
        );
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
