// authority/VDO/VDOScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../PoweredByBikaji.dart';
import '../../Login/workerLogout.dart';
import 'VDOCalendarActivityScreen.dart';
import 'VDOD2DCalnderActivity.dart';
import 'VDOPanchayatCampusCalnderActivity.dart';
import 'VDOPendingWorkerComplaintsCalender.dart';
import 'VDORCCCalendarActivityScreen.dart';
import 'VDOResolvedWorkerComplaintsCalender.dart';
import 'VDOSchoolCampusCalnderActivity.dart';
import 'VDOWagesCalendarActivityScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'fillContractorDetails.dart';

class VDOScreen extends StatefulWidget {
  @override
  _VDOScreenState createState() => _VDOScreenState();
}

class _VDOScreenState extends State<VDOScreen> {
  int totalComplaints = 0;
  int pendingComplaints = 0;
  int resolvedComplaints = 0;
  String? vdgramPanchayat;
  Map<String, int> activityCounts = {};
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchActivityCounts();
    _loadLanguagePreference();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        vdgramPanchayat = prefs.getString('gram_panchayat');
      });
    });
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gramPanchayat = prefs.getString('gram_panchayat');
    print(gramPanchayat);
    if (gramPanchayat != null) {
      final response = await http.get(Uri.parse(
              'https://sbmgrajasthan.com/api/complaints-by-gram-panchayat/')
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

  Future<void> fetchActivityCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? gramPanchayat = prefs.getString('gram_panchayat');
    String? District = prefs.getString('District');

    final response = await http.get(Uri.parse(
        'https://sbmgrajasthan.com/api/gp-activity-count/?district=$District&gp=$gramPanchayat'));

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
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
                    Row(children: [
                      Image.asset(
                        'assets/images/Group.png',
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          vdgramPanchayat!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
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
            Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF5C964A),
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
                  localizations.action,
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
                                    localizations.totalComplaints,
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VDOPendingWorkerComplaintsCalender(),
                              ),
                            );
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
                                    localizations.pending,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VDOResolvedWorkerComplaintsCalender(),
                              ),
                            );
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    localizations.resolved,
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
                          localizations.home,
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
                        spacing: 1,
                        runSpacing: 12,
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
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.8,
    );
  }

  Widget _buildButton(String label, String imageUrl, String routeName,
      String number, BuildContext context) {
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
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.16,
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
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
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
      case 'SchoolCampus':
        return VDOSchoolCampusCalnderActivity(section: 'School Campus');
      case 'PanchayatCampus':
        return VDOPanchayatCampusCalnderActivity(section: 'Panchayat Campus');
      case 'AnimalBodytransport':
        return VDOCalendarActivityScreen(section: 'Animal Transport');
      case 'ContractorDetailsScreen':
        return FillContractorDetailsScreen();
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
