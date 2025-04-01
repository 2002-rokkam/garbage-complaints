// CitizensScreen/CitizensScreen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_2/PoweredByBikaji.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ContactUsPage.dart';
import '../customerLogout.dart';
import 'ComplaintsScreen/ComplaintScreen.dart';
import 'package:intl/intl.dart';
import 'ComplaintsScreen/complaintsBottomBar.dart';

class CitizensScreen extends StatefulWidget {
  @override
  _CitizensScreenState createState() => _CitizensScreenState();
}

class _CitizensScreenState extends State<CitizensScreen> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> buttonItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {
        'label': localizations.villagesCleaned,
        'imageUrl': 'assets/images/villages_cleaned.png',
        'route': 'DoorToDoorScreen',
        'number': '345'
      },
      {
        'label': localizations.swachhtaMitra,
        'imageUrl': 'assets/images/group-discussion 1.png',
        'route': 'RoadSweepingScreen',
        'number': '150'
      },
      {
        'label': localizations.homesShopsCleaned,
        'imageUrl': 'assets/images/shop.png',
        'route': 'DrainCleaningScreen',
        'number': '200'
      },
      {
        'label': localizations.roadsCleaned,
        'imageUrl': 'assets/images/road_sweeping.png',
        'route': 'CSCScreen',
        'number': '120'
      },
      {
        'label': localizations.dumpingYard,
        'imageUrl': 'assets/images/Dumping-Yard.png',
        'route': 'RRCScreen',
        'number': '95'
      },
      {
        'label': localizations.garbageDumped,
        'imageUrl': 'assets/images/Garbage_Dumped.png',
        'route': 'WagesScreen',
        'number': '75'
      },
    ];
  }

  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  late PageController _pageController;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    _loadLanguagePreference();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Fixed image slider
        Container(
          height: 180,
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
                            16), // Rounded corners for the carousel
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 150,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: 3, // Number of images
                            itemBuilder: (context, index) {
                              final images = [
                                'assets/images/m1.png',
                                'assets/images/m2.png',
                                'assets/images/m3.png',
                              ];
                              return Image.asset(
                                images[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.home,
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
                          localizations.clickAndComplaints,
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

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.complaints,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsPage(),
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
                                'assets/images/Actin.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              localizations.helpLine,
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
                                'assets/images/Complaints.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              localizations.complaints,
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
                PoweredByBikaji(),
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
    final localizations = AppLocalizations.of(context)!;
    String appBarTitle = localizations.sbmgRajasthan;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF5C964A),
          automaticallyImplyLeading: false, // Disable the back button
          title: Text(
            appBarTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: localizations.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: localizations.complaints,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: localizations.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, String imageUrl, String routeName,
      String number, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
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
