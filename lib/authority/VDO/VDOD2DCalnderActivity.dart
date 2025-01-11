// authority/VDO/VDOD2DCalnderActivity.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VDOD2DCalnderActivityScreen extends StatefulWidget {
  final String section;

  const VDOD2DCalnderActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _VDOD2DCalnderActivityScreenState createState() =>
      _VDOD2DCalnderActivityScreenState();
}

class _VDOD2DCalnderActivityScreenState extends State<VDOD2DCalnderActivityScreen> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;
  String? workerId; // Make workerId nullable

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchWorkerId(); // Fetch the workerId and update the state
  }

  // Fetch the workerId and then call fetchActivities
  Future<void> _fetchWorkerId() async {
    workerId = await getWorkerId(); // Assign workerId here
    if (workerId != null && workerId!.isNotEmpty) {
      fetchActivities(); // Now call fetchActivities after workerId is available
    } else {
      setState(() {
        _isLoading = false; // Handle the case if workerId is not available
      });
      print('Worker ID not found.');
    }
  }

  Future<String?> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id'); // Return nullable workerId
  }

  Future<void> fetchActivities() async {
    if (workerId == null || workerId!.isEmpty)
      return; // Avoid calling if workerId is null

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
            'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId!,
      'section': widget.section,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extracting activities for the specific section
        var sectionActivities = data['section_data'][widget.section] ?? [];
        setState(() {
          _activities = sectionActivities;
          fetchQRDetails(workerId!); // Pass workerId here
        });
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchQRDetails(String workerId) async {
    if (workerId.isEmpty) return;

    final url = Uri.parse(
            'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'D2D_QR',
      'date': _selectedDate.toIso8601String(),
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails = data['section_data']['D2D_QR'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load QR details');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
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
  if (workerId == null) {
    return Center(child: CircularProgressIndicator()); // Wait for workerId to be fetched
  }

  final selectedActivities = getActivitiesForSelectedDate();

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
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        indicatorColor: Color.fromRGBO(255, 210, 98, 1),
        indicatorWeight: 3.0,
        tabs: [
          Tab(text: 'Before & After'),
          Tab(text: 'QR Data'),
        ],
      ),
    ),
    backgroundColor:  Color.fromRGBO(239, 239, 239, 1),
    body: Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                fetchQRDetails(workerId!); // Use workerId here
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF5C964A),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFFFA726),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    Expanded(
                        child: Card(
                           color: Color.fromRGBO(239, 239, 239, 1),
                          child: ListTile(
                            title: Text('Total Activities'),
                            subtitle: Text('${selectedActivities.length}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BeforeAfterScreen(
                                      selectedDate: _selectedDate,
                                      activities: selectedActivities,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors
                                    .green, // Set the background color to green
                              ),
                              child: Text('View All'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                           color: Color.fromRGBO(239, 239, 239, 1),
                          child: ListTile(
                            title: Text('Total QR Scans'),
                            subtitle: Text('${_tripDetails.length}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QRDetailsScreen(
                                      selectedDate: _selectedDate,
                                      tripDetails: _tripDetails,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors
                                    .green, // Set the background color to green
                              ),
                              child: Text('View All'),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}
    }

class BeforeAfterScreen extends StatelessWidget {
  final List activities;
  final DateTime selectedDate;

  const BeforeAfterScreen(
      {Key? key, required this.activities, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Before & After Details'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: activities.map((activity) {
            return Card(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFFD262), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40.42,
                                height: 40.42,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFFF2C6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(59),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: ShapeDecoration(
                                  color: (activity['status'] ?? 'Pending') ==
                                          'Completed'
                                      ? Color(0xFF5C964A)
                                      : Color(0xFFFFA726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    activity['status'] ?? 'Pending',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 120,
                            height: 26,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                activity['date_time'] ?? 'N/A',
                                style: TextStyle(
                                  color: Color(0xFF252525),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150.10,
                            height: 99.52,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage('${activity['before_image']}'),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          Container(
                            width: 150.10,
                            height: 99.52,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image:
                                    NetworkImage('${activity['after_image']}'),
                                fit: BoxFit.cover,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        children: [
                          Text(
                            '${activity['address']} \nWorked by: ${activity['worker_name']}',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class QRDetailsScreen extends StatelessWidget {
  final List tripDetails;
  final DateTime selectedDate;

  const QRDetailsScreen(
      {Key? key, required this.tripDetails, required this.selectedDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Details'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: tripDetails.isEmpty
            ? Center(
                child: Text('No trip details available for selected date.'))
            : Column(
                children: tripDetails.map((trip) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'QR Scanned Data: ${trip['QRAddress']}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                '${trip['date_time']}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class VDOD2DCalnderActivityScreen extends StatefulWidget {
//   final String section;

//   const VDOD2DCalnderActivityScreen({Key? key, required this.section})
//       : super(key: key);

//   @override
//   _VDOD2DCalnderActivityScreenState createState() =>
//       _VDOD2DCalnderActivityScreenState();
// }

// class _VDOD2DCalnderActivityScreenState
//     extends State<VDOD2DCalnderActivityScreen>
//     with SingleTickerProviderStateMixin {
//   DateTime _selectedDate = DateTime.now();
//   List _activities = [];
//   bool _isLoading = false;
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     fetchActivities();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   Future<String> getWorkerId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('worker_id') ?? "";
//   }

//   Future<void> fetchActivities() async {
//     String workerId = await getWorkerId();

//     setState(() {
//       _isLoading = true;
//     });

//     final url = Uri.parse(
//             'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
//         .replace(queryParameters: {
//       'worker_id': workerId,
//       'section': widget.section,
//     });

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         var sectionActivities = data['section_data'][widget.section] ?? [];
//         setState(() {
//           _activities = sectionActivities;
//         });
//       } else {
//         throw Exception('Failed to load activities');
//       }
//     } catch (e) {
//       print(e);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   List getActivitiesForSelectedDate() {
//     return _activities
//         .where((activity) =>
//             DateTime.parse(activity['date_time']).toLocal().day ==
//                 _selectedDate.day &&
//             DateTime.parse(activity['date_time']).toLocal().month ==
//                 _selectedDate.month &&
//             DateTime.parse(activity['date_time']).toLocal().year ==
//                 _selectedDate.year)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '${widget.section}',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Color(0xFF5C964A),
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.white,
//           indicatorColor: Color.fromRGBO(255, 210, 98, 1),
//           indicatorWeight: 3.0,
//           tabs: [
//             Tab(text: 'Before & After'),
//             Tab(text: 'QR Data'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             child: TableCalendar(
//               focusedDay: _selectedDate,
//               firstDay: DateTime(2000),
//               lastDay: DateTime(2100),
//               calendarFormat: CalendarFormat.month,
//               selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDate = selectedDay;
//                 });

//                 final selectedTabIndex = _tabController.index;
//                 final selectedTab =
//                     selectedTabIndex == 0 ? 'Before & After' : 'QR Data';
//                 final selectedActivities = getActivitiesForSelectedDate();

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ActivitiesScreen(
//                       selectedDate: _selectedDate,
//                       activities: selectedActivities,
//                       tab: selectedTab,
//                     ),
//                   ),
//                 );
//               },
//               calendarStyle: CalendarStyle(
//                 selectedDecoration: BoxDecoration(
//                   color: Color(0xFF5C964A),
//                   shape: BoxShape.circle,
//                 ),
//                 todayDecoration: BoxDecoration(
//                   color: Color(0xFFFFA726),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ActivitiesScreen extends StatelessWidget {
//   final DateTime selectedDate;
//   final List activities;
//   final String tab;

//   const ActivitiesScreen({
//     Key? key,
//     required this.selectedDate,
//     required this.activities,
//     required this.tab,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//             'Activities on ${selectedDate.toLocal().toString().split(' ')[0]}'),
//         backgroundColor: Color(0xFF5C964A), // Green background color
//       ),
//       body: activities.isEmpty
//           ? Center(child: Text('No activities for selected date.'))
//           : ListView.builder(
//               itemCount: activities.length,
//               itemBuilder: (context, index) {
//                 var activity = activities[index];
//                 return Card(
//                   child: tab == 'Before & After'
//                       ? D2DBeforeAfterTab(activity: activity)
//                       : QRDataCard(activity: activity),
//                 );
//               },
//             ),
//     );
//   }
// }

// class D2DBeforeAfterTab extends StatelessWidget {
//   final Map activity;

//   const D2DBeforeAfterTab({Key? key, required this.activity}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Color(0xFFFFD262),
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top Row: Logo, Status, and Date-Time
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 40.42,
//                       height: 40.42,
//                       decoration: ShapeDecoration(
//                         color: Color(0xFFFFF2C6),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(59),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: ShapeDecoration(
//                         color: (activity['status'] ?? 'Pending') == 'Completed'
//                             ? Color(0xFF5C964A)
//                             : Color(0xFFFFA726),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                       ),
//                       child: Center(
//                         child: Text(
//                           activity['status'] ?? 'Pending',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   width: 120,
//                   height: 26,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: ShapeDecoration(
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(26),
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       activity['date_time'] ?? 'N/A',
//                       style: TextStyle(
//                         color: Color(0xFF252525),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             // Before and After Images
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Container(
//                   width: 150.10,
//                   height: 99.52,
//                   decoration: ShapeDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage('${activity['before_image']}'),
//                       fit: BoxFit.cover,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 150.10,
//                   height: 99.52,
//                   decoration: ShapeDecoration(
//                     image: DecorationImage(
//                       image: NetworkImage('${activity['after_image']}'),
//                       fit: BoxFit.cover,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             // Address and Worker Email
//             Wrap(
//               children: [
//                 Text(
//                   '${activity['address']} \nWorked by: ${activity['worker_name']}',
//                   style: TextStyle(
//                     color: Color(0xFF252525),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class QRDataCard extends StatelessWidget {
//   final Map activity;

//   const QRDataCard({Key? key, required this.activity}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.location_on, color: Colors.green),
//               SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'QR Scanned Data: ${activity['QRAddress']}',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(Icons.calendar_today, color: Colors.grey),
//               SizedBox(width: 8),
//               Text(
//                 '${activity['date_time']}',
//                 style: TextStyle(
//                   color: Colors.black87,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
