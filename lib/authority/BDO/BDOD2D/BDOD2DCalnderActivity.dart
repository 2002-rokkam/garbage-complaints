// authority/BDO/BDOD2D/BDOD2DCalnderActivity.dart
import 'package:flutter/material.dart';
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
  String? workerId; // Make workerId nullable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWorkerId(); // Fetch the workerId and update the state
  }

  // Fetch the workerId and then call fetchActivities
  Future<void> _fetchWorkerId() async {
    workerId = await getWorkerId(); // Assign workerId here
    if (workerId != null && workerId!.isNotEmpty) {
      fetchActivities(); // Now call fetchActivities after workerId is available
    } else {
      setState(() {
        _isLoading = false; // Handle the case if workerId is not available
      });
      print('Worker ID not found.');
    }
  }

  Future<String?> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id'); // Return nullable workerId
  }

  Future<void> fetchActivities() async {
    if (workerId == null || workerId!.isEmpty)
      return; // Avoid calling if workerId is null

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
            'https://334e-122-172-86-132.ngrok-free.app/api/bdo-section-dashboard')
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

        // Extracting activities for the specific section
        var sectionActivities = data['section_data'][widget.section] ?? [];
        setState(() {
          _activities = sectionActivities;
          fetchQRDetails(workerId!); // Pass workerId here
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
            'https://334e-122-172-86-132.ngrok-free.app/api/bdo-section-dashboard')
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
        setState(() {
          _tripDetails = data['section_data']['D2D_QR'] ?? [];
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
    if (workerId == null) {
      return Center(
          child:
              CircularProgressIndicator()); // Wait for workerId to be fetched
    }

    final selectedActivities = getActivitiesForSelectedDate();

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
            Tab(text: 'Before & After'),
            Tab(text: 'QR Data'),
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
                  fetchQRDetails(workerId!); // Use workerId here
                });
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
            ),
          ),
          Container(
            height: 80, // Set a fixed height for the entire TabBarView
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      selectedActivities.isNotEmpty
                          ? Card(
                              child: ListTile(
                                title: Text(
                                    'Total Activities : ${selectedActivities.length}'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BDOSelectedDateActivitiesScreen(
                                          selectedDate: _selectedDate,
                                          activities: selectedActivities,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .green, // Set the background color to green
                                  ),
                                  child: Text('View All'),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'No activities for selected date.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                      getFilteredTripDetails().isNotEmpty
                          ? Card(
                              child: ListTile(
                                title: Text(
                                    'Total QR Scans:${getFilteredTripDetails().length}'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QRDetailsScreen(
                                          tripDetails: getFilteredTripDetails(),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .green, // Set the background color to green
                                  ),
                                  child: Text('View All'),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'No QR scans for selected date.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
