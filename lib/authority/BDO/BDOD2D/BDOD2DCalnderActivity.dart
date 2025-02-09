// authority/BDO/BDOD2D/BDOD2DCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../CalnderActivity/BDOSelectedDateActivitiesScreen.dart';
import 'QRDetailsScreen.dart';

class BDOD2DCalnderActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const BDOD2DCalnderActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _BDOD2DCalnderActivityScreenState createState() =>
      _BDOD2DCalnderActivityScreenState();
}

class _BDOD2DCalnderActivityScreenState
    extends State<BDOD2DCalnderActivityScreen>
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
      setState(() => _isLoading = false);
    }
  }

  Future<String?> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id');
  }

  Future<void> fetchActivities() async {
    if (workerId == null || workerId!.isEmpty) return;
    setState(() => _isLoading = true);

    final url = Uri.parse('https://sbmgrajasthan.com/api/bdo-section-dashboard')
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
        setState(() {
          _activities = data['section_data'][widget.section] ?? [];
          fetchQRDetails(workerId!);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchQRDetails(String workerId) async {
    if (workerId.isEmpty) return;
    final url = Uri.parse('https://sbmgrajasthan.com/api/bdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'D2D_QR',
      'district': widget.district,
      'gram_panchayat': widget.gramPanchayat,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails = data['section_data']['D2D_QR'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section),
        backgroundColor: Color(0xFF5C964A),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Before & After'),
            Tab(text: 'QR Data'),
          ],
        ),
      ),
      body: workerId == null
          ? Center(child: CircularProgressIndicator())
          : D2DCalendarActivityBody(
              selectedDate: _selectedDate,
              activities: _activities,
              tripDetails: _tripDetails,
              isLoading: _isLoading,
              tabController: _tabController,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  fetchQRDetails(workerId!);
                });
              },
            ),
    );
  }
}

class D2DCalendarActivityBody extends StatelessWidget {
  final DateTime selectedDate;
  final List activities;
  final List tripDetails;
  final bool isLoading;
  final TabController tabController;
  final Function(DateTime) onDateSelected;

  const D2DCalendarActivityBody({
    Key? key,
    required this.selectedDate,
    required this.activities,
    required this.tripDetails,
    required this.isLoading,
    required this.tabController,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: (selectedDay, focusedDay) =>
              onDateSelected(selectedDay),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: tabController,
                  children: [
                    _buildActivityCard(
                        context,
                        'Total Activities',
                        activities.length,
                        BDOSelectedDateActivitiesScreen(
                            selectedDate: selectedDate,
                            activities: activities)),
                    _buildActivityCard(
                        context,
                        'Total QR Scans',
                        tripDetails.length,
                        QRDetailsScreen(tripDetails: tripDetails)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
      BuildContext context, String title, int count, Widget screen) {
    return Card(
      child: ListTile(
        title: Text('$title: $count'),
        trailing: ElevatedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen)),
          child: Text('View All'),
        ),
      ),
    );
  }
}
