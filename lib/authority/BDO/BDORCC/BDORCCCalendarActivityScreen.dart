// authority/BDO/BDORCC/BDORCCCalendarActivityScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../VDO/VDObefreAfter.dart';
import 'BDOTripDetailsScreen.dart';

class BDORCCCalendarActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const BDORCCCalendarActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _BDORCCCalendarActivityScreenState createState() =>
      _BDORCCCalendarActivityScreenState();
}

class _BDORCCCalendarActivityScreenState
    extends State<BDORCCCalendarActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;

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
      setState(() => _isLoading = true);
      if (_tabController.index == 0) {
        fetchActivities();
      } else {
        fetchTripDetails();
      }
    });
    fetchActivities();
    fetchTripDetails();
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();
    setState(() => _isLoading = true);

    final url = Uri.parse('https://sbmgrajasthan.com/api/bdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': widget.section,
      'district': widget.district,
      'gram_panchayat': widget.gramPanchayat,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var sectionActivities = data['section_data'][widget.section] ?? [];
        setState(() {
          _activities = sectionActivities;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchTripDetails() async {
    String workerId = await getWorkerId();
    setState(() => _isLoading = true);

    final url = Uri.parse('https://sbmgrajasthan.com/api/bdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'Waste Details',
      'district': widget.district,
      'gram_panchayat': widget.gramPanchayat,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails = data['section_data']['Waste Details'] ?? [];
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List getActivitiesForSelectedDate() {
    return _activities.where((activity) {
      DateTime activityDate = DateTime.parse(activity['date_time']).toLocal();
      return isSameDay(activityDate, _selectedDate);
    }).toList();
  }

  List getTripDetailsForSelectedDate() {
    return _tripDetails.where((trip) {
      DateTime tripDate = DateTime.parse(trip['date_time']).toLocal();
      return isSameDay(tripDate, _selectedDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivities = getActivitiesForSelectedDate();
    final selectedTrips = getTripDetailsForSelectedDate();
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF5C964A),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: const Color.fromRGBO(255, 210, 98, 1),
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: localizations.beforeAfter),
            Tab(text: localizations.tripDetails),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  _isLoading = true;
                });

                if (_tabController.index == 0) {
                  fetchActivities().then((_) {
                    final selectedActivities = getActivitiesForSelectedDate();
                    if (selectedActivities.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VDOBeforeAfterScreen(
                              activities: selectedActivities),
                        ),
                      );
                    }
                  });
                } else {
                  fetchTripDetails().then((_) {
                    final selectedTrips = getTripDetailsForSelectedDate();
                    if (selectedTrips.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BDOTripDetailsScreen(tripDetails: selectedTrips),
                        ),
                      );
                    }
                  });
                }
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF5C964A),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFFFA726),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, _) {
                  final isBeforeAfterTab = _tabController.index == 0;
                  final count = isBeforeAfterTab
                      ? _activities.where((activity) {
                          DateTime activityDate =
                              DateTime.parse(activity['date_time']).toLocal();
                          return isSameDay(activityDate, date);
                        }).length
                      : _tripDetails.where((trip) {
                          DateTime tripDate =
                              DateTime.parse(trip['date_time']).toLocal();
                          return isSameDay(tripDate, date);
                        }).length;

                  if (count > 0) {
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: _isLoading
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
                      selectedActivities.isEmpty
                          ? Center(child: Text(localizations.noActivities))
                          : Container(),
                      selectedTrips.isEmpty
                          ? Center(child: Text(localizations.noTripDetails))
                          : Container(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
