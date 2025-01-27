// WokersScreen/Wages/WagesCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WagesCalendarActivityScreen extends StatefulWidget {
  final String section;

  const WagesCalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _WagesCalendarActivityScreenState createState() =>
      _WagesCalendarActivityScreenState();
}

class _WagesCalendarActivityScreenState
    extends State<WagesCalendarActivityScreen> {
  List _activities = [];
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    fetchActivitiesForMonth(_selectedMonth, _selectedYear);
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String workerId = prefs.getString('worker_id') ?? "";
    return workerId;
  }

  Future<void> fetchActivitiesForMonth(int month, int year) async {
    String workerId = await getWorkerId();

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://sbmgrajasthan.com/api/worker/$workerId/section/${widget.section}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _activities = data['activities'].where((activity) {
            DateTime activityDate =
                DateTime.parse(activity['date_time']).toLocal();
            return activityDate.month == month && activityDate.year == year;
          }).toList();
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

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('HH:mm:ss, d/M/yyyy').format(dateTime);
  }

  void _showImageFullscreen(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Image.network(imageUrl),
          ),
        );
      },
    );
  }

  void _showMonthPicker() async {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final selectedMonthIndex = await showDialog<int>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Month',
                  style: TextStyle(
                    color: Color(0xFF5C964A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context, index);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFF5C964A),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: Color(0xFF252525),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedMonthIndex != null) {
      setState(() {
        _selectedMonth = selectedMonthIndex + 1;
      });
      fetchActivitiesForMonth(_selectedMonth, _selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showMonthPicker,
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? Center(child: Text('No activities for the selected month.'))
              : ListView.builder(
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical:
                              8.0), // Adds vertical space between containers
                      child: Container(
                        width: 370,
                        height: 74.67,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/wages.png', // Replace with your logo asset
                                width: 50,
                                height: 50,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formatDateTime(activity['date_time']),
                                    style: TextStyle(
                                      color: Color(0xFF252525),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Replace IconButton with TextButton
                            TextButton(
                              onPressed: () {
                                _showImageFullscreen(activity['before_image']);
                              },
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Color(
                                      0xFF5C964A), // Change to your preferred color
                                  fontSize: 14,
                                ),
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
