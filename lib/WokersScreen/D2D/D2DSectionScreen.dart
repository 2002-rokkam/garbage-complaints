// WokersScreen/D2D/D2DSectionScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../WorkerCommon/D2DBeforeAfterContainer.dart';
import 'D2DCalnderActivity.dart';
import 'QRTab.dart';

class D2DSectionScreen extends StatefulWidget {
  final String section;

  const D2DSectionScreen({Key? key, required this.section}) : super(key: key);

  @override
  _D2DSectionScreenState createState() => _D2DSectionScreenState();
}

class _D2DSectionScreenState extends State<D2DSectionScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> beforeAfterContainers = [];
  bool isLoading = true;
  late TabController _tabController;
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchActivities();
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
      final response = await dio.get(
          'https://sbmgrajasthan.com/api/worker/$workerId/section/${widget.section}');

      if (response.statusCode == 200) {
        final data = response.data;
        List activities = data['activities'];

        setState(() {
          beforeAfterContainers = activities
              .where((activity) => activity['status'] == 'trip started')
              .map((activity) => D2DBeforeAfterContainer(
                    section: widget.section,
                    initialData: activity,
                    onReload: _fetchActivities,
                  ))
              .toList();
        });
      } else {
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

void addNewContainer() {
    // Check if any container has initialData = null
    bool hasEmptyContainer = beforeAfterContainers.any((container) {
      if (container is D2DBeforeAfterContainer) {
        return container.initialData == null;
      }
      return false;
    });

    if (hasEmptyContainer) {
      // Show a message or prevent adding a new container
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add a new container while one is incomplete.'),
        ),
      );
      return;
    }

    setState(() {
      beforeAfterContainers.add(D2DBeforeAfterContainer(
        section: widget.section,
        initialData: null,
        onReload: _fetchActivities,
      ));
    });
  }

  // void addNewContainer() {
  //   setState(() {
  //     beforeAfterContainers.add(D2DBeforeAfterContainer(
  //       section: widget.section,
  //       initialData: null,
  //       onReload: _fetchActivities,
  //     ));
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                        D2DCalnderActivityScreen(section: widget.section),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: localizations.beforeAfter),
              Tab(text: localizations.qr),
              Tab(text: localizations.gps),
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
            QRTab(),
            _buildGPSTab(),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton.extended(
                onPressed: addNewContainer,
                backgroundColor: const Color(0xFFFFD262),
                label: Row(
                  children: [
                    Icon(Icons.add, size: 24, color: Color(0xFF252525)),
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
              )
            : null,
      ),
    );
  }

  Widget _buildBeforeAfterTab() {
    return isLoading
        ? Center(
            child: Image.asset(
              'assets/images/Loder.gif',
              width: 200,
              height: 200,
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: beforeAfterContainers.isNotEmpty
                  ? beforeAfterContainers
                  : [
                      D2DBeforeAfterContainer(
                        section: widget.section,
                        onReload: _fetchActivities,
                      ),
                    ],
            ),
          );
  }

  Widget _buildGPSTab() {
    return const Center(
      child: Text(
        "GPS Tab Content",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
