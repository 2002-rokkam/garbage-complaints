// authority/D2DSectionScreen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BeforeAfterContainer.dart';
import 'QRTab.dart'; // Add this package

class D2DSectionScreen extends StatefulWidget {
  final String section;

  const D2DSectionScreen({Key? key, required this.section}) : super(key: key);

  @override
  _D2DSectionScreenState createState() => _D2DSectionScreenState();
}

class _D2DSectionScreenState extends State<D2DSectionScreen> {
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
          'https://8250-122-172-86-111.ngrok-free.app/api/worker/$workerId/section/${widget.section}');

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5C964A),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                '${widget.section}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Before After"),
              Tab(text: "QR"),
              Tab(text: "GPS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBeforeAfterTab(),
            QRTab(), // Using the stateless QRTab widget here
            _buildGPSTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addNewContainer,
          backgroundColor: const Color(0xFFFFD262),
          label: Row(
            children: const [
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

  Widget _buildGPSTab() {
    return Center(
      child: Text(
        "GPS Tab Content",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
