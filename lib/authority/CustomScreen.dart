// authority/CustomScreen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BeforeAfterContainer.dart';
import 'History.dart';

class ResponsiveScreen extends StatefulWidget {
  final String section;

  const ResponsiveScreen({Key? key, required this.section}) : super(key: key);

  @override
  _ResponsiveScreenState createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  List<Widget> beforeAfterContainers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      isLoading = true;
    });

    Future<int> getWorkerId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int workerId = prefs.getInt('worker_id') ?? -1;
      return workerId;
    }

    try {
      int workerId = await getWorkerId();
      Dio dio = Dio();
      final response = await dio.get(
          'https://f827-2401-4900-882e-cef3-39e1-4161-da52-3ce0.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

      if (response.statusCode == 200) {
        final data = response.data;
        List activities = data['activities'];

        setState(() {
          beforeAfterContainers = activities
              .where((activity) => activity['status'] == 'trip started')
              .map((activity) => BeforeAfterContainer(
                    section: widget.section,
                    initialData: activity,
                    onReload: _fetchActivities,
                  ))
              .toList();
        });
      } else {
        print("Error fetching activities: ${response.data['message']}");
      }
    } catch (e) {
      print("Error fetching activities: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void addNewContainer() {
    setState(() {
      beforeAfterContainers.add(BeforeAfterContainer(
        section: widget.section,
        initialData: null,
        onReload: _fetchActivities,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFF5C964A),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Text(
                '${widget.section}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () {
                // Navigate to the new CalendarScreen and pass the section
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CalendarActivityScreen(section: widget.section),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: isLoading
              ? [Center(child: CircularProgressIndicator())]
              : beforeAfterContainers.isNotEmpty
                  ? beforeAfterContainers
                  : [
                      BeforeAfterContainer(
                        section: widget.section,
                        onReload: _fetchActivities,
                      ),
                    ],
        ),
      ),
      // Floating action button will stay fixed at the bottom of the screen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewContainer,
        backgroundColor: Color(0xFFFFD262),
        label: Row(
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: Color(0xFF252525),
            ),
            SizedBox(width: 12),
            Text(
              'Add More',
              style: TextStyle(
                color: Color(0xFF252525),
                fontSize: 14,
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
