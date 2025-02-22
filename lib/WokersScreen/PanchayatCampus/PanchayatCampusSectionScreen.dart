// WokersScreen/PanchayatCampus/PanchayatCampusSectionScreen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../WorkerCommon/BeforeAfterContainer.dart';
import 'PanchayatCampusCalnderActivity.dart';

class PanchayatCampusSectionScreen extends StatefulWidget {
  final String section;

  const PanchayatCampusSectionScreen({Key? key, required this.section}) : super(key: key);

  @override
  _PanchayatCampusSectionScreenState createState() => _PanchayatCampusSectionScreenState();
}

class _PanchayatCampusSectionScreenState extends State<PanchayatCampusSectionScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> beforeAfterContainers = [];
  List<Widget> ToiletbeforeAfterContainers = [];

  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchActivities();
    _fetchToiletActivities();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      // Trigger UI update when tab changes
    });
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
      final response = await dio.get('https://bd0f-122-172-86-18.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

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

   Future<void> _fetchToiletActivities() async {
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
      final response = await dio.get('https://bd0f-122-172-86-18.ngrok-free.app/api/worker/$workerId/section/Panchayat Toilet');

      if (response.statusCode == 200) {
        final data = response.data;
        List activities = data['activities'];

        setState(() {
          ToiletbeforeAfterContainers = activities
              .where((activity) => activity['status'] == 'trip started')
              .map((activity) => BeforeAfterContainer(
                    section: "Panchayat Toilet",
                    initialData: activity,
                    onReload: _fetchToiletActivities,
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

  void addToiletContainer() {
    setState(() {
      ToiletbeforeAfterContainers.add(BeforeAfterContainer(
        section: "Panchayat Toilet",
        initialData: null,
        onReload: _fetchToiletActivities,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5C964A),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.section}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PanchayatCampusActivityScreen(section: widget.section),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Campus"),
              Tab(text: "Toilet"),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: const Color.fromRGBO(255, 210, 98, 1),
            indicatorWeight: 3.0,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBeforeAfterTab(),
            _SchoolToiletBeforeAfterTab(),
          ],
        ),
        floatingActionButton: (_tabController.index == 0)
            ? FloatingActionButton.extended(
                onPressed: addNewContainer,
                backgroundColor: const Color(0xFFFFD262),
                label: Row(
                  children: const [
                    Icon(Icons.add, size: 24, color: Color(0xFF252525)),
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
            : FloatingActionButton.extended(
                onPressed: addToiletContainer,
                backgroundColor: const Color(0xFFFFD262),
                label: Row(
                  children: const [
                    Icon(Icons.add, size: 24, color: Color(0xFF252525)),
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
      ),
    );
  }

  Widget _buildBeforeAfterTab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
          );
  }

   Widget _SchoolToiletBeforeAfterTab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ToiletbeforeAfterContainers.isNotEmpty
                  ? ToiletbeforeAfterContainers
                  : [
                      BeforeAfterContainer(
                        section: "Panchayat Toilet",
                        onReload: _fetchToiletActivities,
                      ),
                    ],
            ),
          );
  }
}