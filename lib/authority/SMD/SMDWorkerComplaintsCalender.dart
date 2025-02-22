// authority/SMD/SMDWorkerComplaintsCalender.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BDO/BDOWorkerComplaintsListScreenCalender.dart';

class SMDWorkerComplaintsCalender extends StatefulWidget {
  @override
  _SMDWorkerComplaintsCalenderState createState() =>
      _SMDWorkerComplaintsCalenderState();
}

class _SMDWorkerComplaintsCalenderState
    extends State<SMDWorkerComplaintsCalender> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, int> complaintCounts = {};
  List<dynamic> complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaintData();
  }

  Future<void> _fetchComplaintData() async {
    final prefs = await SharedPreferences.getInstance();
    final District = prefs.getString('District') ?? '';

    final url =
        'https://bd0f-122-172-86-18.ngrok-free.app/api/complaintdetails-by-state';

    try {
      final response = await http.get(Uri.parse(url));
      print(response);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final complaintsList = data['complaints'];

        Map<DateTime, int> counts = {};
        for (var complaint in complaintsList) {
          final date = DateTime.parse(complaint['created_at']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          complaints = complaintsList;
          complaintCounts = counts;
        });
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  List getComplaintsForSelectedDate() {
    return complaints.where((complaint) {
      final date = DateTime.parse(complaint['created_at']).toLocal();
      return date.year == _selectedDay.year &&
          date.month == _selectedDay.month &&
          date.day == _selectedDay.day;
    }).toList();
  }

  void _onViewPressed() {
    final selectedComplaints = getComplaintsForSelectedDate();
    if (selectedComplaints.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BDOWorkerComplaintsListScreenCalender(
            date: _selectedDay,
            complaints: complaints,
            onUpdate: _fetchComplaintData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No complaints for this date.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedSelectedDay =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    int complaintCount = complaintCounts[normalizedSelectedDay] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C964A),
        toolbarHeight: 80.0,
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _selectedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final count = complaintCounts[
                        DateTime(date.year, date.month, date.day)] ??
                    0;
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
          SizedBox(height: 16),
          complaintCount > 0
              ? Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text('Total Complaints: $complaintCount'),
                    trailing: ElevatedButton(
                      onPressed: _onViewPressed,
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
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No complaints available",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}
