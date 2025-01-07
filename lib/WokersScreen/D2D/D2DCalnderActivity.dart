// WokersScreen/D2D/D2DCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchActivities();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
    return workerId;
  }

  Future<void> fetchActivities() async {
    int workerId = await getWorkerId();

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://cc33-122-172-85-145.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _activities = data['activities'];
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print(e);
    } finally {
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
    final selectedActivities = getActivitiesForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.section}',
          style: TextStyle(
            color: Colors.white, // White text color
            fontSize: 20, // Optional: Adjust font size
            fontWeight: FontWeight.bold, // Optional: Bold text
          ),
        ),
        backgroundColor: Color(0xFF5C964A), // Green background color
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white, // Set label color to white
          unselectedLabelColor:
              Colors.white, // Unselected tabs will also be white
          indicatorColor: Color.fromRGBO(
              255, 210, 98, 1), // The selected tab underline color
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: 'Before & After'),
            Tab(text: 'QR Data'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendar Section
          Container(
            height: MediaQuery.of(context).size.height * 0.4, // 1/4 of screen
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF5C964A), // Green color for selected date
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFFFA726), // Optional: Orange for today
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Total Activities Summary
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total activities done on ${_selectedDate.toLocal().toString().split(' ')[0]} = ${selectedActivities.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // TabBarView for Before & After and Trip Details
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : selectedActivities.isEmpty
                    ? Center(child: Text('No activities for selected date.'))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          D2DBeforeAfterTab(activities: selectedActivities),
                          D2DQRDetailsTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class D2DBeforeAfterTab extends StatelessWidget {
  final List activities;

  const D2DBeforeAfterTab({Key? key, required this.activities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: activities.map((activity) {
          return Card(
            child: Container(
              width: 370,
              height: 201.88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFFFD262),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Status, and Date-Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40.42,
                              height: 40.42,
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFF2C6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(59),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                color: (activity['status'] ?? 'Pending') ==
                                        'Completed'
                                    ? Color(0xFF5C964A)
                                    : Color(0xFFFFA726),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  activity['status'] ?? 'Pending',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 120,
                          height: 26,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              activity['date_time'] ?? 'N/A',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Before and After Images
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 150.10,
                          height: 99.52,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://cc33-122-172-85-145.ngrok-free.app${activity['before_image']}',
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        Container(
                          width: 150.10,
                          height: 99.52,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://cc33-122-172-85-145.ngrok-free.app${activity['after_image']}',
                              ),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class D2DQRDetailsTab extends StatefulWidget {
  const D2DQRDetailsTab({Key? key}) : super(key: key);

  @override
  _D2DQRDetailsTabState createState() => _D2DQRDetailsTabState();
}

class _D2DQRDetailsTabState extends State<D2DQRDetailsTab> {
  bool _isLoading = true;
  List _tripDetails = [];

  @override
  void initState() {
    super.initState();
    initializeWorkerIdAndFetchDetails();
  }

  Future<void> initializeWorkerIdAndFetchDetails() async {
    workerId = await getWorkerId();
    if (workerId != -1) {
      fetchTripDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle the case where workerId is not available
      print('Worker ID not found.');
    }
  }

  Future<void> fetchTripDetails() async {
    final url = Uri.parse(
        'https://cc33-122-172-85-145.ngrok-free.app/api/worker/$workerId/section/D2D_QR');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails =
              data['activities']; // Extracting activities from the response
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  late int workerId;

  Future<int> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int workerId = prefs.getInt('worker_id') ?? -1;
    return workerId;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tripDetails.isEmpty
              ? Center(child: Text('No trip details available.'))
              : Column(
                  children: _tripDetails.map((trip) {
                    return Card(
                      elevation: 4, // Adds a shadow for depth
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
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
                                    overflow: TextOverflow.ellipsis,
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
    );
  }
}
