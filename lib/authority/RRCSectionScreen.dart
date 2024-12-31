// authority/RRCSectionScreen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BeforeAfterContainer.dart';
import 'TripDetailCard.dart'; // HTTP requests
class RRCScreen extends StatefulWidget {
  final String section;

  const RRCScreen({Key? key, required this.section}) : super(key: key);

  @override
  _RRCScreenState createState() => _RRCScreenState();
}

class _RRCScreenState extends State<RRCScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Widget> beforeAfterContainers = [];
  List tripDetails = []; // Keeping it empty, no API call for trip details
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      isLoading = true;
    });

    Future<int> getWorkerId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt('worker_id') ?? -1;
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
          // Trip details API call is removed
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
      appBar: AppBar(
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Before After'),
            Tab(text: 'Trip Details'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Before After Containers
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: beforeAfterContainers.isNotEmpty
                        ? beforeAfterContainers
                        : [
                            BeforeAfterContainer(
                              section: widget.section,
                              onReload: _fetchActivities,
                            ),
                          ],
                  ),
                ),

                // Tab 2: Trip Details (Now Static or Empty)
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Displaying one or more TripDetailCard widgets statically
                      TripDetailCard(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
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
            )
          : null,
    );
  }
}