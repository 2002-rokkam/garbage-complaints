// authority/BDO/BDOWorkerComplaintsCalender.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'BDOWorkerComplaintsListScreenCalender.dart'; // Import SharedPreferences

class BDOWorkerComplaintsCalender extends StatefulWidget {
  @override
  _BDOWorkerComplaintsCalenderState createState() =>
      _BDOWorkerComplaintsCalenderState();
}

class _BDOWorkerComplaintsCalenderState
    extends State<BDOWorkerComplaintsCalender> {
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, int> complaintCounts = {};
  List<dynamic> complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaintData();
  }

  // Fetch gram_panchayat from SharedPreferences and use it in the API call
  Future<void> _fetchComplaintData() async {
    final prefs = await SharedPreferences.getInstance();
    final District = prefs.getString('District') ?? '';

    final url =
        'https://sbmgrajasthan.com/api/complaintdetails-by-district/?district=$District';

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

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BDOWorkerComplaintsListScreenCalender(
          date: selectedDay,
          complaints: complaints,
          onUpdate: _fetchComplaintData, // Pass the refresh method
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Complaints',
          style: TextStyle(
            color: Colors.white, // White text color
            fontSize: 20, // Optional: Adjust font size
            fontWeight: FontWeight.bold, // Optional: Bold text
          ),
        ),
        backgroundColor: Color(0xFF5C964A), // Set green color for the app bar
        toolbarHeight: 80.0, // Set a custom height for the app bar
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDateSelected,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF5C964A), // Green color for selected date
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFFFA726), // Optional: Orange for today
                shape: BoxShape.circle,
              ),
              outsideDecoration: BoxDecoration(
                color: Colors
                    .transparent, // Keep outside days transparent if needed
              ),
              defaultDecoration: BoxDecoration(
                color: Colors
                    .transparent, // Regular days have transparent background
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final count = complaintCounts[date] ?? 0;
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
          )
        ],
      ),
    );
  }
}
