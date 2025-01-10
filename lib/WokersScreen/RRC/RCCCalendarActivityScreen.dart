// WokersScreen/RRC/RCCCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
        'https://c035-122-172-86-134.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

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
          // TabBarView for Before & After and Trip Details
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : selectedActivities.isEmpty
                    ? Center(child: Text('No activities for selected date.'))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RRCBeforeAfterTab(
                            activities: selectedActivities,
                            totalActivities: selectedActivities.length,
                          ),
                          TripDetailsTab(selectedDate: _selectedDate),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class RRCBeforeAfterTab extends StatelessWidget {
  final List activities;
  final int totalActivities;

  const RRCBeforeAfterTab(
      {Key? key, required this.activities, required this.totalActivities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total activities done on ${DateTime.now().toLocal().toString().split(' ')[0]} = $totalActivities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ...activities.map((activity) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150.10,
                            height: 99.52,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage('${activity['before_image']}'),
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
                                image:
                                    NetworkImage('${activity['after_image']}'),
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
        ],
      ),
    );
  }
}

class TripDetailsTab extends StatefulWidget {
  final DateTime selectedDate;

  const TripDetailsTab({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  _TripDetailsTabState createState() => _TripDetailsTabState();
}

class _TripDetailsTabState extends State<TripDetailsTab> {
  bool _isLoading = true;
  List _tripDetails = [];
  late String workerId;

  @override
  void initState() {
    super.initState();
    initializeWorkerIdAndFetchDetails();
  }

  Future<void> initializeWorkerIdAndFetchDetails() async {
    workerId = await getWorkerId();
    if (workerId.isNotEmpty) {
      fetchTripDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Worker ID not found.');
    }
  }

  Future<void> fetchTripDetails() async {
    final url = Uri.parse(
        'https://c035-122-172-86-134.ngrok-free.app/api/worker/$workerId/section/Waste Details');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails = data['activities']; // Extracting activities
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

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  List getTripsForSelectedDate() {
    return _tripDetails.where((trip) {
      final tripDate = DateTime.parse(trip['date_time']).toLocal();
      return tripDate.year == widget.selectedDate.year &&
          tripDate.month == widget.selectedDate.month &&
          tripDate.day == widget.selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTrips = getTripsForSelectedDate();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total trips on ${widget.selectedDate.toLocal().toString().split(' ')[0]} = ${selectedTrips.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : selectedTrips.isEmpty
                  ? Center(child: Text('No trip details for selected date.'))
                  : Column(
                      children: selectedTrips.map((trip) {
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
        ],
      ),
    );
  }
}
