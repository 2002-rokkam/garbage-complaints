// WokersScreen/RRC/RRCSectionScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../WorkerCommon/BeforeAfterContainer.dart';
import 'RCCCalendarActivityScreen.dart';
import 'TripDetailCard.dart';

class RRCScreen extends StatefulWidget {
  final String section;

  const RRCScreen({Key? key, required this.section}) : super(key: key);

  @override
  _RRCScreenState createState() => _RRCScreenState();
}

class _RRCScreenState extends State<RRCScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Widget> beforeAfterContainers = [];
  List tripDetails = [];
  bool isLoading = true;

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
    _loadLanguagePreference();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      isLoading = true;
    });

    Future<String> getWorkerId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('worker_id') ?? "";
    }

    try {
      String workerId = await getWorkerId();
      Dio dio = Dio();
      final response = await dio.get(
          'https://sbmgrajasthan.com/api/worker/$workerId/section/${widget.section}');

      if (response.statusCode == 200) {
        final data = response.data;
        List activities = data['activities'];

        setState(() {
          beforeAfterContainers = activities
              .where((activity) => activity['status'] == 'trip started')
              .map((activity) => BeforeAfterContainer(
                    section: widget.section,
                    initialData: activity,
                    onReload: _fetchActivities,
                  ))
              .toList();
        });
      } else {}
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addNewContainer() {
    setState(() {
      beforeAfterContainers.add(BeforeAfterContainer(
        section: widget.section,
        initialData: null,
        onReload: _fetchActivities,
      ));
    });
  }

  // Navigate to the new screen and send section data
  void navigateToNewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RCCCalendarActivityScreen(
            section: widget.section), // Send section data
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C964A),
        centerTitle: false, // Don't center the title
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center title in the row
          children: [
            Text(
              widget.section,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Make back button white
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white, // Make calendar icon white
            ),
            onPressed: navigateToNewScreen,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Set label color to white
          unselectedLabelColor:
              Colors.white, // Unselected tabs will also be white
          indicatorColor: const Color.fromRGBO(
              255, 210, 98, 1), // The selected tab underline color
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Before After'),
            Tab(text: 'Trip Details'),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: Image.asset(
                'assets/images/Loder.gif',
                width: 200,
                height: 200,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Before After Containers
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: beforeAfterContainers.isNotEmpty
                        ? beforeAfterContainers
                        : [
                            BeforeAfterContainer(
                              section: widget.section,
                              onReload: _fetchActivities,
                            ),
                          ],
                  ),
                ),
                // Tab 2: Trip Details (Static or Empty)
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TripDetailCard(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: addNewContainer,
              backgroundColor: const Color(0xFFFFD262),
              label: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 24,
                    color: Color(0xFF252525),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.addMore,
                    style: const TextStyle(
                      color: Color(0xFF252525),
                      fontSize: 14,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
