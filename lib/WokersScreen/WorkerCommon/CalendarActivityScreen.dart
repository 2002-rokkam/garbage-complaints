// WokersScreen/WorkerCommon/CalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarActivityScreen extends StatefulWidget {
  final String section;

  const CalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _CalendarActivityScreenState createState() => _CalendarActivityScreenState();
}

class _CalendarActivityScreenState extends State<CalendarActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchActivities();
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
    final activityCount = selectedActivities.length;

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
      ),
      body: Column(
        children: [
          // Calendar Section
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
          // Activity Card Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text('Activities: $activityCount'),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (activityCount > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedDateActivitiesScreen(
                            selectedDate: _selectedDate,
                            activities: selectedActivities,
                          ),
                        ),
                      );
                    } else {
                      // Optionally show a message when no activities exist for the selected date.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No activities for this date.")),
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
            ),
          ),
        ],
      ),
    );
  }
}


class SelectedDateActivitiesScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List activities;

  const SelectedDateActivitiesScreen({
    Key? key,
    required this.selectedDate,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activities on ${selectedDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            color: Colors.white, // White text color
            fontSize: 20, // Adjust font size if needed
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
        backgroundColor: Color(0xFF5C964A), // Green background color
      ),
      body: activities.isEmpty
          ? Center(child: Text('No activities for selected date.'))
          : SingleChildScrollView(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            ),
    );
  }
}
