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

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";
    return workerId;
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();

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
          // TabBarView for Before & After and Trip Details
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : selectedActivities.isEmpty
                    ? Center(child: Text('No activities for selected date.'))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          D2DBeforeAfterTab(
                              activities: selectedActivities,
                              selectedDate: _selectedDate),
                          D2DQRDetailsTab(selectedDate: _selectedDate),
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
  final DateTime selectedDate;

  const D2DBeforeAfterTab(
      {Key? key, required this.activities, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter activities based on selected date
    List filteredActivities = activities.where((activity) {
      DateTime activityDate = DateTime.parse(activity['date_time']).toLocal();
      return activityDate.year == selectedDate.year &&
          activityDate.month == selectedDate.month &&
          activityDate.day == selectedDate.day;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Display Total Activities Count
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total activities done on ${selectedDate.toLocal().toString().split(' ')[0]} = ${filteredActivities.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Display activities
          filteredActivities.isEmpty
              ? Center(child: Text('No activities for selected date.'))
              : Column(
                  children: filteredActivities.map((activity) {
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
                              // Top Row: Logo, Status, and Date-Time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40.42,
                                        height: 40.42,
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFFFF2C6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(59),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: ShapeDecoration(
                                          color: (activity['status'] ??
                                                      'Pending') ==
                                                  'Completed'
                                              ? Color(0xFF5C964A)
                                              : Color(0xFFFFA726),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 150.10,
                                    height: 99.52,
                                    decoration: ShapeDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${activity['before_image']}',
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
                                          '${activity['after_image']}',
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
                              SizedBox(height: 8),
                              Text(
                                activity['address'] ?? 'No Address',
                                style: TextStyle(
                                  color: Color(0xFF252525),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}


class D2DQRDetailsTab extends StatefulWidget {
  final DateTime selectedDate;

  const D2DQRDetailsTab({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  _D2DQRDetailsTabState createState() => _D2DQRDetailsTabState();
}

class _D2DQRDetailsTabState extends State<D2DQRDetailsTab> {
  bool _isLoading = true;
  List _tripDetails = [];

  @override
  void initState() {
    super.initState();
    fetchTripDetails();
  }

  Future<void> fetchTripDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";

    if (workerId.isNotEmpty) {
      final url = Uri.parse(
          'https://cc33-122-172-85-145.ngrok-free.app/api/worker/$workerId/section/D2D_QR');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _tripDetails = data['activities'];
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
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Worker ID not found.');
    }
  }

  List getQRActivitiesForSelectedDate(DateTime selectedDate) {
    return _tripDetails.where((trip) {
      DateTime tripDate = DateTime.parse(trip['date_time']).toLocal();
      return tripDate.year == selectedDate.year &&
          tripDate.month == selectedDate.month &&
          tripDate.day == selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List filteredQRActivities =
        getQRActivitiesForSelectedDate(widget.selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total QR activities on ${widget.selectedDate.toLocal().toString().split(' ')[0]} = ${filteredQRActivities.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                filteredQRActivities.isEmpty
                    ? Center(child: Text('No QR activities for selected date.'))
                    : Column(
                        children: filteredQRActivities.map((trip) {
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
                                      Icon(Icons.location_on,
                                          color: Colors.green),
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
                                      Icon(Icons.calendar_today,
                                          color: Colors.grey),
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
              ],
            ),
    );
  }
}
