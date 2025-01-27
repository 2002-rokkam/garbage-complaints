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
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  String? workerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWorkerId();
  }

  Future<void> _fetchWorkerId() async {
    workerId = await getWorkerId();
    if (workerId != null && workerId!.isNotEmpty) {
      fetchActivities();
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
        setState(() {
          _activities = sectionActivities;
          fetchQRDetails(workerId!);
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
        var filteredQRDetails = qrDetails.where((qr) {
          DateTime qrDate = DateTime.parse(qr['date_time']).toLocal();
          return qrDate.day == _selectedDate.day &&
              qrDate.month == _selectedDate.month &&
              qrDate.year == _selectedDate.year;
        }).toList();

        setState(() {
          _tripDetails = filteredQRDetails;
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
      return Center(child: CircularProgressIndicator());
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
                  _isLoading = true; // Show loading when a new date is selected
                });
                fetchActivities(); // Fetch activities for the new selected date
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
          // Cleaning image below the calendar

          Container(
            height: 100,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Before & After Activities Card
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: Text('Total Activities'),
                            subtitle: Text('${selectedActivities.length}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BeforeAfterScreen(
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
                        ),
                      ),
                      // QR Data Activities Card
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: Text('Total QR Scans'),
                            subtitle: Text('${_tripDetails.length}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRDetailsScreen(
                                      selectedDate: _selectedDate,
                                      tripDetails: _tripDetails,
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

class BeforeAfterScreen extends StatelessWidget {
  final List activities;
  final DateTime selectedDate;

  const BeforeAfterScreen(
      {Key? key, required this.activities, required this.selectedDate})
      : super(key: key);

  void _showFullScreenImage(BuildContext context, String imageUrl,
      double dirlatitude, double dirlongitude, String time) async {
    String location =
        'Lat: ${dirlatitude.toStringAsFixed(6)}, Long: ${dirlongitude.toStringAsFixed(6)}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 370,
                    height: 45,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.23),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 370,
                    height: 45,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.23),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(activities[0]['created_at']).toLocal();
    String createdAttime =
        '${createdAt.hour}:${createdAt.minute}:${createdAt.second}';

    final updated_at = DateTime.parse(activities[0]['updated_at']).toLocal();
    String updated_attime =
        '${updated_at.hour}:${updated_at.minute}:${updated_at.second}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Before & After Details'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: activities.map((activity) {
            return Card(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFFD262), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showFullScreenImage(
                                context,
                                activity['before_image'],
                                activity['latitude_before'] ?? 0.0,
                                activity['longitude_before'] ?? 0.0,
                                createdAttime,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 150.10,
                                  height: 99.52,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          '${activity['before_image']}'),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    color: Colors.black54,
                                    child: Text(
                                      '${DateTime.parse(activity['created_at']).toLocal().hour}:${DateTime.parse(activity['created_at']).toLocal().minute}:${DateTime.parse(activity['created_at']).toLocal().second}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showFullScreenImage(
                                context,
                                activity['after_image'],
                                activity['latitude_after'] ?? 0.0,
                                activity['longitude_after'] ?? 0.0,
                                updated_attime,
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 150.10,
                                  height: 99.52,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          '${activity['after_image']}'),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    color: Colors.black54,
                                    child: Text(
                                      '${DateTime.parse(activity['updated_at']).toLocal().hour}:${DateTime.parse(activity['updated_at']).toLocal().minute}:${DateTime.parse(activity['created_at']).toLocal().second}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
