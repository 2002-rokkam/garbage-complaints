// WokersScreen/SchoolCampus/SchoolCampusCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../WorkerCommon/CalnderActivityBeforeAfterScreen.dart';

class SchoolCampusActivityScreen extends StatefulWidget {
  final String section;

  const SchoolCampusActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _SchoolCampusActivityScreenState createState() =>
      _SchoolCampusActivityScreenState();
}

class _SchoolCampusActivityScreenState extends State<SchoolCampusActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _PanchayatDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  String? workerId;
  Map<DateTime, int> activityCounts = {};
  Map<DateTime, int> PanchayatCounts = {};
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchWorkerId();
  }

  Future<void> _fetchWorkerId() async {
    workerId = await getWorkerId();
    if (workerId != null && workerId!.isNotEmpty) {
      fetchActivities();
      fetchPanchayatActivities();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<String?> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id');
  }

  Future<void> fetchActivities() async {
    if (workerId == null || workerId!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://sbmgrajasthan.com/api/worker/$workerId/section/${widget.section}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var sectionActivities = data['activities'];

        Map<DateTime, int> counts = {};
        for (var activity in sectionActivities) {
          final date = DateTime.parse(activity['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _activities = sectionActivities;
          activityCounts = counts;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPanchayatActivities() async {
    if (workerId == null || workerId!.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://sbmgrajasthan.com/api/worker/$workerId/section/School Toilet');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var sectionActivities = data['activities'];

        Map<DateTime, int> counts = {};
        for (var activity in sectionActivities) {
          final date = DateTime.parse(activity['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _PanchayatDetails = sectionActivities;
          PanchayatCounts = counts;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print(e);
    }
  }

  List getPanchayatActivitiesForSelectedDate() {
    return _PanchayatDetails.where((activity) =>
        DateTime.parse(activity['date_time']).toLocal().day ==
            _selectedDate.day &&
        DateTime.parse(activity['date_time']).toLocal().month ==
            _selectedDate.month &&
        DateTime.parse(activity['date_time']).toLocal().year ==
            _selectedDate.year).toList();
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
    if (workerId == null) {
      return Center(child: CircularProgressIndicator());
    }

    final selectedActivities = getActivitiesForSelectedDate();
    final PanchayatActivities = getPanchayatActivitiesForSelectedDate();

    final isBeforeAfterTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.section}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C964A),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Color.fromRGBO(255, 210, 98, 1),
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: 'Panchayat Campus'),
            Tab(text: 'Panchayat Toilet'),
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
                _isLoading = true;
              });
              if (_tabController.index == 0 && selectedActivities.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalnderActivityBeforeAfterScreen(
                      selectedDate: _selectedDate,
                      activities: selectedActivities,
                    ),
                  ),
                );
              } else if (_tabController.index == 1 &&
                  PanchayatActivities.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalnderActivityBeforeAfterScreen(
                      selectedDate: _selectedDate,
                      activities: PanchayatActivities,
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
                    : PanchayatCounts[
                            DateTime(date.year, date.month, date.day)] ??
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                (_tabController.index == 0 && selectedActivities.isNotEmpty) ||
                        (_tabController.index == 1 &&
                            PanchayatActivities.isNotEmpty)
                    ? Container()
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No activities available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
