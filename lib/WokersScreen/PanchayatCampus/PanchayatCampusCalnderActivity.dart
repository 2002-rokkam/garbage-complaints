// WokersScreen/PanchayatCampus/PanchayatCampusCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PanchayatCampusActivityScreen extends StatefulWidget {
  final String section;

  const PanchayatCampusActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _PanchayatCampusActivityScreenState createState() =>
      _PanchayatCampusActivityScreenState();
}

class _PanchayatCampusActivityScreenState extends State<PanchayatCampusActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  String? workerId;
  Map<DateTime, int> activityCounts = {};
  Map<DateTime, int> qrCounts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes
    });
    _fetchWorkerId();
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
        'https://bd0f-122-172-86-18.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

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
        'https://bd0f-122-172-86-18.ngrok-free.app/api/worker/$workerId/section/Panchayat Toilet');
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
      return Center(child: CircularProgressIndicator());
    }

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
              fetchActivities();
              fetchQRDetails(workerId!);
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
            child:
                (_tabController.index == 0 && selectedActivities.isNotEmpty) ||
                        (_tabController.index == 1 && _tripDetails.isNotEmpty)
                    ? Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            _tabController.index == 0
                                ? 'Total Activities: ${selectedActivities.length}'
                                : 'Total QR Scans: ${_tripDetails.length}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              if (_tabController.index == 0 &&
                                  selectedActivities.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BeforeAfterScreen(
                                      selectedDate: _selectedDate,
                                      activities: selectedActivities,
                                    ),
                                  ),
                                );
                              } else if (_tabController.index == 1 &&
                                  _tripDetails.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BeforeAfterScreen(
                                      selectedDate: _selectedDate,
                                      activities: _tripDetails,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('View'),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF5C964A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      )
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
        title: Text('Panchayat Details'),
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