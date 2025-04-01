// authority/BDO/BDOD2D/BDOD2DCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../CalnderActivity/BDOSelectedDateActivitiesScreen.dart';
import 'QRDetailsScreen.dart';

class BDOD2DCalnderActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const BDOD2DCalnderActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _BDOD2DCalnderActivityScreenState createState() =>
      _BDOD2DCalnderActivityScreenState();
}

class _BDOD2DCalnderActivityScreenState
    extends State<BDOD2DCalnderActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  Map<DateTime, int> activityCounts = {};
  Map<DateTime, int> qrCounts = {};
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    fetchActivities();
    fetchTripDetails();
    _loadLanguagePreference();
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();

    setState(() {
      _isLoading = true;
    });

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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchTripDetails() async {
    String workerId = await getWorkerId();

    final url = Uri.parse('https://sbmgrajasthan.com/api/bdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'D2D_QR',
      'district': widget.district,
      'gram_panchayat': widget.gramPanchayat,
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var qrDetails = data['section_data']['D2D_QR'] ?? [];

        Map<DateTime, int> counts = {};
        for (var qr in qrDetails) {
          final date = DateTime.parse(qr['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _tripDetails = qrDetails;
          qrCounts = counts;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {}
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

  List getFilteredTripDetails() {
    return _tripDetails
        .where((trip) =>
            DateTime.parse(trip['date_time']).toLocal().day ==
                _selectedDate.day &&
            DateTime.parse(trip['date_time']).toLocal().month ==
                _selectedDate.month &&
            DateTime.parse(trip['date_time']).toLocal().year ==
                _selectedDate.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isBeforeAfterTab = _tabController.index == 0;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section),
        backgroundColor: Color(0xFF5C964A),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Color.fromRGBO(255, 210, 98, 1),
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: localizations.beforeAfter),
            Tab(text: localizations.scanQR), 
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

              final selectedDateKey = DateTime(
                  selectedDay.year, selectedDay.month, selectedDay.day);
              final count = isBeforeAfterTab
                  ? activityCounts[selectedDateKey] ?? 0
                  : qrCounts[selectedDateKey] ?? 0;

              if (count > 0) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (isBeforeAfterTab) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BDOSelectedDateActivitiesScreen(
                          selectedDate: _selectedDate,
                          activities: getActivitiesForSelectedDate(),
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRDetailsScreen(
                          tripDetails: getFilteredTripDetails(),
                        ),
                      ),
                    );
                  }
                });
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
                    : qrCounts[DateTime(date.year, date.month, date.day)] ?? 0;

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
