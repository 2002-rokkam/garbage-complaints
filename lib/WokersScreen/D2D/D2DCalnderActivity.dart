// WokersScreen/D2D/D2DCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../WorkerCommon/CalnderActivityBeforeAfterScreen.dart';

class D2DCalnderActivityScreen extends StatefulWidget {
  final String section;

  const D2DCalnderActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _D2DCalnderActivityScreenState createState() =>
      _D2DCalnderActivityScreenState();
}

class _D2DCalnderActivityScreenState extends State<D2DCalnderActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  String? workerId;
  Map<DateTime, int> activityCounts = {};
  Map<DateTime, int> qrCounts = {};
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

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> _fetchWorkerId() async {
    workerId = await getWorkerId();
    if (workerId != null && workerId!.isNotEmpty) {
      fetchActivities();
      fetchQRDetails(workerId!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> fetchQRDetails(String workerId) async {
    if (workerId.isEmpty) return;

    final url = Uri.parse(
        'https://sbmgrajasthan.com/api/worker/$workerId/section/D2D_QR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var qrDetails = data['activities'];

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
        throw Exception('Failed to load QR details');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
      return Center(child: Image.asset(
                  'assets/images/Loder.gif', 
                  width: 200, 
                  height: 200,
                ));
    }
    final localizations = AppLocalizations.of(context)!;
    final selectedActivities = getActivitiesForSelectedDate();
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
            Tab(text: localizations.beforeAfter),
            Tab(text: localizations.qrData),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: Image.asset(
                'assets/images/Loder.gif', // Your custom loader image
                width: 200,
                height: 200,
              ),
            )
          : Column(
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
              final count = _tabController.index == 0
                  ? activityCounts[selectedDateKey] ?? 0
                  : qrCounts[selectedDateKey] ?? 0;

              if (count > 0) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (_tabController.index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalnderActivityBeforeAfterScreen(
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
                          selectedDate: _selectedDate,
                          tripDetails: _tripDetails,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: (_tabController.index == 0 && selectedActivities.isEmpty)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        localizations.noActivities,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : (_tabController.index == 1 && _tripDetails.isEmpty)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            localizations
                                .noActivities, // Use localization for consistency
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(),
          ),
        ],
      ),
    );
  }
}

class QRDetailsScreen extends StatelessWidget {
  final List tripDetails;
  final DateTime selectedDate;

  const QRDetailsScreen(
      {Key? key, required this.tripDetails, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Details'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: tripDetails.isEmpty
            ? Center(
                child: Text('No trip details available for selected date.'))
            : Column(
                children: tripDetails.map((trip) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'QR Scanned Data: ${trip['QRAddress']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                '${trip['date_time']}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
