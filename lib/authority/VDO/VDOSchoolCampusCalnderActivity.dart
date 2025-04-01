// authority/VDO/VDOSchoolCampusCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'VDObefreAfter.dart';

class VDOSchoolCampusCalnderActivity extends StatefulWidget {
  final String section;

  const VDOSchoolCampusCalnderActivity({Key? key, required this.section})
      : super(key: key);

  @override
  _VDOSchoolCampusCalnderActivityState createState() =>
      _VDOSchoolCampusCalnderActivityState();
}

class _VDOSchoolCampusCalnderActivityState
    extends State<VDOSchoolCampusCalnderActivity>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  Map<DateTime, int> activityCounts = {};
  Map<DateTime, int> tripCounts = {};
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchData();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> _fetchData() async {
    String workerId = await getWorkerId();
    fetchActivities(workerId);
    fetchTripDetails(workerId);
  }

  Future<void> fetchActivities(String workerId) async {
    final url = Uri.parse('https://sbmgrajasthan.com/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': widget.section,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var sectionActivities = data['section_data'][widget.section] ?? [];

        Map<DateTime, int> counts = {};
        for (var activity in sectionActivities) {
          final date = DateTime.parse(activity['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _activities = sectionActivities;
          activityCounts = counts;
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {}
  }

  Future<void> fetchTripDetails(String workerId) async {
    final url = Uri.parse('https://sbmgrajasthan.com/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'School Toilet',
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var trips = data['section_data']['School Toilet'] ?? [];

        Map<DateTime, int> counts = {};
        for (var trip in trips) {
          final date = DateTime.parse(trip['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _tripDetails = trips;
          tripCounts = counts;
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {}
  }

  List getPanchayatActivitiesForSelectedDate() {
    return _tripDetails
        .where((activity) =>
            DateTime.parse(activity['date_time']).toLocal().day ==
                _selectedDate.day &&
            DateTime.parse(activity['date_time']).toLocal().month ==
                _selectedDate.month &&
            DateTime.parse(activity['date_time']).toLocal().year ==
                _selectedDate.year)
        .toList();
  }

  List getActivitiesForSelectedDate() {
    return _activities
        .where((activity) =>
            DateTime.parse(activity['date_time']).toLocal().day ==
                _selectedDate.day &&
            DateTime.parse(activity['date_time']).toLocal().month ==
                _selectedDate.month &&
            DateTime.parse(activity['date_time']).toLocal().year ==
                _selectedDate.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isBeforeAfterTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section),
        backgroundColor: Color(0xFF5C964A),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Color.fromRGBO(255, 210, 98, 1),
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.campus),
            Tab(text: AppLocalizations.of(context)!.toilet),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              if (_tabController.index == 0 &&
                  getActivitiesForSelectedDate().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VDOBeforeAfterScreen(
                      activities: getActivitiesForSelectedDate(),
                    ),
                  ),
                );
              } else if (_tabController.index == 1 &&
                  getPanchayatActivitiesForSelectedDate().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VDOBeforeAfterScreen(
                      activities: getPanchayatActivitiesForSelectedDate(),
                    ),
                  ),
                );
              }
            },
            calendarStyle: CalendarStyle(
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
                final count = isBeforeAfterTab
                    ? activityCounts[
                            DateTime(date.year, date.month, date.day)] ??
                        0
                    : tripCounts[DateTime(date.year, date.month, date.day)] ??
                        0;
                if (count > 0) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
