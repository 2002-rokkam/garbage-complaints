// WokersScreen/WorkerCommon/ActionScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BeforeAfterContainer.dart';
import 'CalendarActivityScreen.dart';

class ActionScreen extends StatefulWidget {
  final String section;

  const ActionScreen({Key? key, required this.section}) : super(key: key);

  @override
  _ActionScreenState createState() => _ActionScreenState();
}

class _ActionScreenState extends State<ActionScreen> {
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

    Future<String> getWorkerId() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String workerId = prefs.getString('worker_id') ?? "";
      return workerId;
    }

    try {
      String workerId = await getWorkerId();
      Dio dio = Dio();
      final response = await dio.get(
          'https://sbmgrajasthan.com/api/worker/$workerId/section/${widget.section}');

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
        final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFF5C964A),
          centerTitle: true,
          automaticallyImplyLeading: false, // To remove the default back button
          title: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Ensures space between the elements
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context); // Handle back navigation
                },
              ),
              Text(
                '${widget.section}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () {
                  // Navigate to the CalendarScreen
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
              localizations.addMore,
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
