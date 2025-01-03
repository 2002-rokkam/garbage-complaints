// authority/RCCCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Main screen to manage the TabController
class RCCCalendarActivityScreen extends StatefulWidget {
  final String section;

  const RCCCalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _RCCCalendarActivityScreenState createState() =>
      _RCCCalendarActivityScreenState();
}

class _RCCCalendarActivityScreenState extends State<RCCCalendarActivityScreen>
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
        'https://8250-122-172-86-111.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

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
          tabs: [
            Tab(text: 'Before & After'),
            Tab(text: 'Trip Details'),
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
                          // Before & After Tab
                          BeforeAfterTab(activities: selectedActivities),
                          // Trip Details Tab
                          TripDetailsTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class BeforeAfterTab extends StatelessWidget {
  final List activities;

  const BeforeAfterTab({Key? key, required this.activities}) : super(key: key);

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
                                'https://8250-122-172-86-111.ngrok-free.app${activity['before_image']}',
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
                                'https://8250-122-172-86-111.ngrok-free.app${activity['after_image']}',
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

class TripDetailsTab extends StatefulWidget {
  const TripDetailsTab({Key? key}) : super(key: key);

  @override
  _TripDetailsTabState createState() => _TripDetailsTabState();
}

class _TripDetailsTabState extends State<TripDetailsTab> {
  bool _isLoading = true;
  List _tripDetails = [];

  @override
  void initState() {
    super.initState();
    fetchTripDetails();
  }

  Future<void> fetchTripDetails() async {
    final url = Uri.parse(
        'https://8250-122-172-86-111.ngrok-free.app/api/worker/4/section/Waste Details');

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tripDetails.isEmpty
              ? Center(child: Text('No trip details available.'))
              : Column(
                  children: _tripDetails.map((trip) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trips: ${trip['trips']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Quantity of Waste: ${trip['quantity_waste']} kg',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Segregated Degradable: ${trip['segregated_degradable']} kg',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Segregated Non-Degradable: ${trip['segregated_non_degradable']} kg',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Segregated Plastic: ${trip['segregated_plastic']} kg',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date: ${trip['date_time']}',
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 14,
                              ),
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
