// authority/BDO/BDOScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../PoweredByBikaji.dart';
import '../../Login/workerLogout.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'BDOPanchayatCampus/BDOPanchayatCampus.dart';
import 'BDOPendingWorkerComplaintsCalender.dart';
import 'BDOResolvedWorkerComplaintsCalender.dart';
import 'BDOSchoolCampus/BDOSchoolCampusCalnderActivity.dart';
import 'selectRegion.dart';
import 'CalnderActivity/BDOCalendarActivityScreen.dart';
import 'BDOD2D/BDOD2DCalnderActivity.dart';
import 'BDORCC/BDORCCCalendarActivityScreen.dart';
import 'BDOWages/BDOWagesCalendarActivityScreen.dart';
import 'contractorDetails.dart';

class BDOScreen extends StatefulWidget {
  @override
  _BDOScreenState createState() => _BDOScreenState();
}

class _BDOScreenState extends State<BDOScreen> {
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int resolvedComplaints = 0;
  late Locale _locale;
  Map<String, int> activityCounts = {};
  String? appbarselectedGramPanchayat;
  String? District;

  @override
  void initState() {
    _loadLanguagePreference();
    super.initState();
    fetchData();
    fetchActivityCounts();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        appbarselectedGramPanchayat =
            prefs.getString('appbarselectedGramPanchayat');
        District = prefs.getString('District');
      });
    });
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? District = prefs.getString('District');
    String? appbarselectedGramPanchayat =
        prefs.getString('appbarselectedGramPanchayat');
    String apiUrl;

    if (appbarselectedGramPanchayat == null ||
        appbarselectedGramPanchayat.isEmpty) {
      apiUrl =
          'https://sbmgrajasthan.com/api/complaints-by-district/?district=$District';
    } else {
      apiUrl =
          'https://sbmgrajasthan.com/api/complaints-by-gram-panchayat/?gram_panchayat=$appbarselectedGramPanchayat';
    }

    final response = await http.get(Uri.parse(apiUrl));

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
  }

  Future<void> fetchActivityCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? district = prefs.getString('District');
    String? appbarselectedGramPanchayat =
        prefs.getString('appbarselectedGramPanchayat');
    print(appbarselectedGramPanchayat);
    String apiUrl;

    if (appbarselectedGramPanchayat == null ||
        appbarselectedGramPanchayat.isEmpty) {
      apiUrl =
          'https://sbmgrajasthan.com/api/district-activity-count/?district=$district';
    } else {
      apiUrl =
          'https://sbmgrajasthan.com/api/gp-activity-count/?district=$district&gp=$appbarselectedGramPanchayat';
    }
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        activityCounts = {
          'Door to Door': data['Door to Door'] ?? 0,
          'Road Sweeping': data['Road Sweeping'] ?? 0,
          'Drainage Cleaning': data['Drainage Cleaning'] ?? 0,
          'CSC': data['CSC'] ?? 0,
          'RRC': data['RRC'] ?? 0,
          'Wages': data['Wages'] ?? 0,
          'School Campus': data['School Campus'] ?? 0,
          'Panchayat Campus': data['Panchayat Campus'] ?? 0,
          'Animal Transport': data['Animal Transport'] ?? 0,
        };
      });
    } else {
      throw Exception('Failed to load activity data');
    }
  }

  List<Map<String, dynamic>> buttonItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return [
      {
        'label': localizations.door_to_door,
        'imageUrl': 'assets/images/d2d.png',
        'route': 'DoorToDoorScreen',
        'number': activityCounts['Door to Door']?.toString() ?? '0'
      },
      {
        'label': localizations.road_sweeping,
        'imageUrl': 'assets/images/road_sweeping.png',
        'route': 'RoadSweepingScreen',
        'number': activityCounts['Road Sweeping']?.toString() ?? '0'
      },
      {
        'label': localizations.drain_cleaning,
        'imageUrl': 'assets/images/drainage_collectin.png',
        'route': 'DrainCleaningScreen',
        'number': activityCounts['Drainage Cleaning']?.toString() ?? '0'
      },
      {
        'label': localizations.community_service_centre,
        'imageUrl': 'assets/images/CSC.png',
        'route': 'CSCScreen',
        'number': activityCounts['CSC']?.toString() ?? '0'
      },
      {
        'label': localizations.resource_recovery_centre,
        'imageUrl': 'assets/images/RRC.png',
        'route': 'RRCScreen',
        'number': activityCounts['RRC']?.toString() ?? '0'
      },
      {
        'label': localizations.wages,
        'imageUrl': 'assets/images/wages.png',
        'route': 'WagesScreen',
        'number': activityCounts['Wages']?.toString() ?? '0'
      },
      {
        'label': localizations.school_campus_sweeping,
        'imageUrl': 'assets/images/SchoolCampus.png',
        'route': 'SchoolCampus',
        'number': activityCounts['School Campus']?.toString() ?? '0'
      },
      {
        'label': localizations.panchayat_campus,
        'imageUrl': 'assets/images/PanchayatCampus.png',
        'route': 'PanchayatCampus',
        'number': activityCounts['Panchayat Campus']?.toString() ?? '0'
      },
      {
        'label': localizations.animal_body_transport,
        'imageUrl': 'assets/images/AnimalBodytransport.png',
        'route': 'AnimalBodytransport',
        'number': activityCounts['Animal Transport']?.toString() ?? '0'
      },
      {
        'label': localizations.contractor_details,
        'imageUrl': 'assets/images/Contractors.png',
        'route': 'ContractorDetailsScreen',
        "number": ""
      },
    ];
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
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/Group.png',
                          color: Colors.white,
                          width: 24,
                          height: 24,
                        ), // Add your icon here
                        GestureDetector(
                          onTap: () async {
                            bool? shouldReload = await showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Container(
                                  height: 400,
                                  padding: EdgeInsets.all(16.0),
                                  child: RegionSelector(),
                                ),
                              ),
                            );

                            if (shouldReload == true) {
                              setState(() {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BDOScreen()),
                                );
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              appbarselectedGramPanchayat == null ||
                                      appbarselectedGramPanchayat!.isEmpty
                                  ? District ?? ''
                                  : appbarselectedGramPanchayat!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                )
              ],
            ),
          ),
        ),
        backgroundColor: Color.fromRGBO(239, 239, 239, 1),
        body: Column(
          children: [
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
                    height: screenHeight * 0.14,
                    decoration: BoxDecoration(
                      color: Color(0xFF5C964A),
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
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/mainimage.png',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? appbarselectedGramPanchayat =
                                prefs.getString('appbarselectedGramPanchayat');
                            if (appbarselectedGramPanchayat == null ||
                                appbarselectedGramPanchayat.isEmpty) {
                              bool? shouldReload = await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    height: 400,
                                    padding: EdgeInsets.all(16.0),
                                    child: RegionSelector(),
                                  ),
                                ),
                              );
                              if (shouldReload == true) {
                                setState(() {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BDOScreen()),
                                  );
                                });
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BDOPendingWorkerComplaintsCalender(),
                                ),
                              );
                            }
                          },
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
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
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String? appbarselectedGramPanchayat =
                                prefs.getString('appbarselectedGramPanchayat');

                            if (appbarselectedGramPanchayat == null ||
                                appbarselectedGramPanchayat.isEmpty) {
                              bool? shouldReload = await showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Container(
                                    height: 400, // Adjust height as needed
                                    padding: EdgeInsets.all(16.0),
                                    child: RegionSelector(),
                                  ),
                                ),
                              );
                              if (shouldReload == true) {
                                setState(() {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BDOScreen()),
                                  );
                                });
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BDOResolvedWorkerComplaintsCalender(),
                                ),
                              );
                            }
                          },
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
                        children: buttonItems(context).map((item) {
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

  Widget _buildButton(String label, String imageUrl, String routeName,
      String number, BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPage(routeName, context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.17,
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
              number,
              style: const TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 24,
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
      ),
    );
  }

  Future<Widget> _getPage(String routeName, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? appbarselectedDistrict = prefs.getString('appbarselectedDistrict');
    String? appbarselectedBlock = prefs.getString('appbarselectedBlock');
    String? appbarselectedGramPanchayat =
        prefs.getString('appbarselectedGramPanchayat');

    if (appbarselectedDistrict == null ||
        appbarselectedDistrict.isEmpty ||
        appbarselectedBlock == null ||
        appbarselectedBlock.isEmpty ||
        appbarselectedGramPanchayat == null ||
        appbarselectedGramPanchayat.isEmpty) {
      // Show the region selection dialog
      bool? shouldReload = await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            height: 400, // Adjust height as needed
            padding: EdgeInsets.all(16.0),
            child: RegionSelector(),
          ),
        ),
      );
      if (shouldReload == true) {
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BDOScreen()),
          );
        });
      }
      return Scaffold(); // Return an empty scaffold to prevent navigation
    }

    switch (routeName) {
      case 'DoorToDoorScreen':
        return BDOD2DCalnderActivityScreen(
          section: 'Door to Door',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'RoadSweepingScreen':
        return BDOCalendarActivityScreen(
          section: 'Road Sweeping',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'DrainCleaningScreen':
        return BDOCalendarActivityScreen(
          section: 'Drainage Cleaning',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'CSCScreen':
        return BDOCalendarActivityScreen(
          section: 'CSC',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'RRCScreen':
        return BDORCCCalendarActivityScreen(
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
      case 'SchoolCampus':
        return BDOSchoolCampusCalnderActivityScreen(
          section: 'School Campus',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'PanchayatCampus':
        return BDOPanchayatCampusCalnderActivityScreen(
          section: 'Panchayat Campus',
          district: appbarselectedDistrict,
          block: appbarselectedBlock,
          gramPanchayat: appbarselectedGramPanchayat,
        );
      case 'AnimalBodytransport':
        return BDOCalendarActivityScreen(
          section: 'Animal Transport',
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
