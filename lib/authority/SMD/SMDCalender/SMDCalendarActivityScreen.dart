// authority/SMD/SMDCalender/SMDCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../commonActvityCalnder.dart';
import '../../BDO/CalnderActivity/BDOSelectedDateActivitiesScreen.dart';

class SMDCalendarActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const SMDCalendarActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _SMDCalendarActivityScreenState createState() =>
      _SMDCalendarActivityScreenState();
}

class _SMDCalendarActivityScreenState extends State<SMDCalendarActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];

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
    setState(() {});

    final url = Uri.parse(
            'https://334e-122-172-86-132.ngrok-free.app/api/bdo-section-dashboard')
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
      setState(() {});
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
        onDateSelected: (selectedDate) {
          setState(() {
            _selectedDate = selectedDate;
          });
        },
        onViewAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BDOSelectedDateActivitiesScreen(
                selectedDate: _selectedDate,
                activities: getActivitiesForSelectedDate(),
              ),
            ),
          );
        },
      ),
    );
  }
}
