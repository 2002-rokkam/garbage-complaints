// authority/VDO/VDOCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../commonActvityCalnder.dart';
import '../BDO/CalnderActivity/BDOSelectedDateActivitiesScreen.dart';

class VDOCalendarActivityScreen extends StatefulWidget {
  final String section;

  const VDOCalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _VDOCalendarActivityScreenState createState() =>
      _VDOCalendarActivityScreenState();
}

class _VDOCalendarActivityScreenState extends State<VDOCalendarActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  Map<DateTime, int> activityCounts = {};

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();

    final url = Uri.parse('https://sbmgrajasthan.com/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': widget.section,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        var sectionActivities = data['section_data'][widget.section] ?? [];

        Map<DateTime, int> counts = {};
        for (var activity in sectionActivities) {
          final date = DateTime.parse(activity['date_time']).toLocal();
          final day = DateTime(date.year, date.month, date.day);
          counts[day] = (counts[day] ?? 0) + 1;
        }

        setState(() {
          _activities = sectionActivities;
          activityCounts = counts;
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print(e);
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
      ),
      body: ActivityCalendar(
        section: widget.section,
        initialDate: _selectedDate,
        activities: _activities,
        activityCounts: activityCounts,
        onDateSelected: (selectedDate) {
          setState(() {
            _selectedDate = selectedDate;
          });
          if (getActivitiesForSelectedDate().isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BDOSelectedDateActivitiesScreen(
                selectedDate: _selectedDate,
                activities: getActivitiesForSelectedDate(),
              ),
            ),
          );          
          }
        },
      ),
    );
  }
}
