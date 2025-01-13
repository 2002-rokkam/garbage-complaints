// authority/BDO/BDOWages/BDOWagesCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BDOWagesCalendarActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const BDOWagesCalendarActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _WagesCalendarActivityScreenState createState() =>
      _WagesCalendarActivityScreenState();
}

class _WagesCalendarActivityScreenState
    extends State<BDOWagesCalendarActivityScreen> {
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

    final url = Uri.parse('http://167.71.230.247/api/bdo-section-dashboard')
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
        setState(() {
          _activities = sectionActivities;
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

  int getWagesCountForDate(DateTime date) {
    final selectedActivities = _activities
        .where((activity) =>
            DateTime.parse(activity['date_time']).toLocal().day == date.day &&
            DateTime.parse(activity['date_time']).toLocal().month ==
                date.month &&
            DateTime.parse(activity['date_time']).toLocal().year == date.year)
        .toList();
    return selectedActivities.length; // Count of activities for selected date
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: Column(
        children: [
          Container(
            height: screenSize.height * 0.4,
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
          // Card to show wages count for the selected date
          GestureDetector(
            onTap: () {
              // When the card is tapped, navigate to the next screen for that date
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivitiesForDateScreen(
                    selectedDate: _selectedDate,
                    activities: _activities,
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wages Count:${getWagesCountForDate(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5C964A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivitiesForDateScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List activities;

  ActivitiesForDateScreen(
      {required this.selectedDate, required this.activities});

  @override
  Widget build(BuildContext context) {
    final selectedActivities = activities
        .where((activity) =>
            DateTime.parse(activity['date_time']).toLocal().day ==
                selectedDate.day &&
            DateTime.parse(activity['date_time']).toLocal().month ==
                selectedDate.month &&
            DateTime.parse(activity['date_time']).toLocal().year ==
                selectedDate.year)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Activities for ${DateFormat.yMMMd().format(selectedDate)}'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: selectedActivities.isEmpty
          ? Center(child: Text('No activities for selected date.'))
          : ListView.builder(
              itemCount: selectedActivities.length,
              itemBuilder: (context, index) {
                final activity = selectedActivities[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFFFD262),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(
                                  DateTime.parse(activity['date_time'])),
                              style: TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  '${activity['before_image']}',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Worked by: ${activity['worker_name']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
