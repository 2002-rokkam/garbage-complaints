// authority/VDO/VDORCCCalendarActivityScreen.dart
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class VDORCCCalendarActivityScreen extends StatefulWidget {
//   final String section;

//   const VDORCCCalendarActivityScreen({Key? key, required this.section})
//       : super(key: key);

//   @override
//   _VDORCCCalendarActivityScreenState createState() =>
//       _VDORCCCalendarActivityScreenState();
// }

// class _VDORCCCalendarActivityScreenState
//     extends State<VDORCCCalendarActivityScreen>
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
//     String workerId = prefs.getString('worker_id') ?? "";
//     return workerId;
//   }

//   Future<void> fetchActivities() async {
//     String workerId = await getWorkerId();

//     setState(() {
//       _isLoading = true;
//     });

//             final url = Uri.parse(
//             'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
//         .replace(queryParameters: {
//       'worker_id': workerId,
//       'section': widget.section,
//     });

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         // Extracting activities for the specific section
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
//     final selectedActivities = getActivitiesForSelectedDate();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           '${widget.section}',
//           style: TextStyle(
//             color: Colors.white, // White text color
//             fontSize: 20, // Optional: Adjust font size
//             fontWeight: FontWeight.bold, // Optional: Bold text
//           ),
//         ),
//         backgroundColor: Color(0xFF5C964A), // Green background color
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: Colors.white, // Set label color to white
//           unselectedLabelColor:
//               Colors.white, // Unselected tabs will also be white
//           indicatorColor: Color.fromRGBO(
//               255, 210, 98, 1), // The selected tab underline color
//           indicatorWeight: 3.0,
//           tabs: [
//             Tab(text: 'Before & After'),
//             Tab(text: 'Trip Details'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           // Calendar Section
//           Container(
//             height: MediaQuery.of(context).size.height * 0.4, // 1/4 of screen
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
//               },
//               calendarStyle: CalendarStyle(
//                 selectedDecoration: BoxDecoration(
//                   color: Color(0xFF5C964A), // Green color for selected date
//                   shape: BoxShape.circle,
//                 ),
//                 todayDecoration: BoxDecoration(
//                   color: Color(0xFFFFA726), // Optional: Orange for today
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//           // Total Activities Summary
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Total activities done on ${_selectedDate.toLocal().toString().split(' ')[0]} = ${selectedActivities.length}',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           // TabBarView for Before & After and Trip Details
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : selectedActivities.isEmpty
//                     ? Center(child: Text('No activities for selected date.'))
//                     : TabBarView(
//                         controller: _tabController,
//                         children: [
//                           // Before & After Tab
//                           RRCBeforeAfterTab(activities: selectedActivities),
//                           // Trip Details Tab
//                           TripDetailsTab(),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RRCBeforeAfterTab extends StatelessWidget {
//   final List activities;

//   const RRCBeforeAfterTab({Key? key, required this.activities})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: activities.map((activity) {
//           return Card(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: Color(0xFFFFD262),
//                   width: 1,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize
//                       .min, // This allows the container to grow based on content
//                   children: [
//                     // Top Row: Logo, Status, and Date-Time
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 40.42,
//                               height: 40.42,
//                               decoration: ShapeDecoration(
//                                 color: Color(0xFFFFF2C6),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(59),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 5),
//                               decoration: ShapeDecoration(
//                                 color: (activity['status'] ?? 'Pending') ==
//                                         'Completed'
//                                     ? Color(0xFF5C964A)
//                                     : Color(0xFFFFA726),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(18),
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   activity['status'] ?? 'Pending',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           width: 120,
//                           height: 26,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 5),
//                           decoration: ShapeDecoration(
//                             color: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(26),
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               activity['date_time'] ?? 'N/A',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     // Before and After Images
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Container(
//                           width: 150.10,
//                           height: 99.52,
//                           decoration: ShapeDecoration(
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                 '${activity['before_image']}',
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: 150.10,
//                           height: 99.52,
//                           decoration: ShapeDecoration(
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                 '${activity['after_image']}',
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     // Address and Worker Email
//                     Wrap(
//                       children: [
//                         Text(
//                           '${activity['address']} \nWorked by: ${activity['worker_name']}',
//                           style: TextStyle(
//                             color: Color(0xFF252525),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class TripDetailsTab extends StatefulWidget {
//   const TripDetailsTab({Key? key}) : super(key: key);

//   @override
//   _TripDetailsTabState createState() => _TripDetailsTabState();
// }

// class _TripDetailsTabState extends State<TripDetailsTab> {
//   bool _isLoading = true;
//   List _tripDetails = [];
//   String workerId = ""; // Initialize workerId with an empty string

//   @override
//   void initState() {
//     super.initState();
//     initializeWorkerIdAndFetchDetails();
//   }

//   Future<void> initializeWorkerIdAndFetchDetails() async {
//     workerId = await getWorkerId(); // Assign workerId here
//     if (workerId.isNotEmpty) {
//       await fetchTripDetails(); // Ensure fetchTripDetails is awaited
//     } else {
//       setState(() {
//         _isLoading = false;
//       });
//       // Handle the case where workerId is not available
//       print('Worker ID not found.');
//     }
//   }

//   Future<void> fetchTripDetails() async {
//     final url = Uri.parse(
//             'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
//         .replace(queryParameters: {
//       'worker_id': workerId,
//       'section': 'Waste Details',
//     });
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           // Extracting the 'Waste Details' from the response
//           _tripDetails = data['section_data']['Waste Details'];
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load trip details');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error: $e');
//     }
//   }

//   Future<String> getWorkerId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('worker_id') ?? "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _tripDetails.isEmpty
//               ? Center(child: Text('No trip details available.'))
//               : Column(
//                   children: _tripDetails.map((trip) {
//                     return Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Displaying worker email (worker_name)
//                             Text(
//                               'Worker Email: ${trip['worker_name']}',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Trips: ${trip['trips']}',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Quantity of Waste: ${trip['quantity_waste']} kg',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Segregated Degradable: ${trip['segregated_degradable']} kg',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Segregated Non-Degradable: ${trip['segregated_non_degradable']} kg',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Segregated Plastic: ${trip['segregated_plastic']} kg',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               'Date: ${trip['date_time']}',
//                               style: TextStyle(
//                                 color: Color(0xFF252525),
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VDORCCCalendarActivityScreen extends StatefulWidget {
  final String section;

  const VDORCCCalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _VDORCCCalendarActivityScreenState createState() =>
      _VDORCCCalendarActivityScreenState();
}

class _VDORCCCalendarActivityScreenState
    extends State<VDORCCCalendarActivityScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];
  List _tripDetails = [];
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchActivities();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
            'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': widget.section,
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchTripDetails() async {
    String workerId = await getWorkerId();

    final url = Uri.parse(
            'https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'Waste Details',
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _tripDetails = data['section_data']['Waste Details']
              .where((trip) =>
                  DateTime.parse(trip['date_time']).toLocal().day ==
                  _selectedDate.day)
              .toList();
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      print('Error: $e');
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
            Tab(text: 'Trip Details'),
          ],
        ),
      ),
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
                });
                fetchTripDetails();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total activities done on ${_selectedDate.toLocal().toString().split(' ')[0]} = ${selectedActivities.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : selectedActivities.isEmpty
                    ? Center(child: Text('No activities for selected date.'))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Activities: ${selectedActivities.length}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          if (_tabController.index == 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BeforeAfterScreen(
                                                  activities:
                                                      selectedActivities,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TripDetailsScreen(
                                                  tripDetails: _tripDetails,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('View All'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Trip Details: ${_tripDetails.length}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                     
                                      TextButton(
                                        onPressed: () {
                                          if (_tabController.index == 0) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BeforeAfterScreen(
                                                  activities:
                                                      selectedActivities,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TripDetailsScreen(
                                                  tripDetails: _tripDetails,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text('View All'),
                                      ),
                                    ],
                                  ),
                                ],
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

class TripDetailsScreen extends StatelessWidget {
  final List tripDetails;

  const TripDetailsScreen({Key? key, required this.tripDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: tripDetails.isEmpty
          ? Center(
              child: Text('No trip details available for the selected date.'))
          : SingleChildScrollView(
              child: Column(
                children: tripDetails.map((trip) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worker Email: ${trip['worker_name']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Trips: ${trip['trips']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Quantity of Waste: ${trip['quantity_waste']} kg',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Segregated Degradable: ${trip['segregated_degradable']} kg',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Segregated Non-Degradable: ${trip['segregated_non_degradable']} kg',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Segregated Plastic: ${trip['segregated_plastic']} kg',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Date: ${trip['date_time']}',
                            style: TextStyle(
                              color: Color(0xFF252525),
                              fontSize: 14,
                            ),
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


class BeforeAfterScreen extends StatelessWidget {
  final List activities;

  const BeforeAfterScreen({Key? key, required this.activities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Before & After'),
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
                  border: Border.all(
                    color: Color(0xFFFFD262),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                image: NetworkImage('${activity['before_image']}'),
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
                                image: NetworkImage('${activity['after_image']}'),
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

// class TripDetailsScreen extends StatefulWidget {
//   final String workerId;
//   final DateTime selectedDate;

//   const TripDetailsScreen({Key? key, required this.workerId, required this.selectedDate}) : super(key: key);

//   @override
//   _TripDetailsScreenState createState() => _TripDetailsScreenState();
// }

// class _TripDetailsScreenState extends State<TripDetailsScreen> {
//   bool _isLoading = true;
//   List _tripDetails = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchTripDetails();
//   }

//   Future<void> fetchTripDetails() async {
//     final url = Uri.parse('https://cc33-122-172-85-145.ngrok-free.app/api/vdo-section-dashboard')
//         .replace(queryParameters: {
//       'worker_id': widget.workerId,
//       'section': 'Waste Details',
//     });
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _tripDetails = data['section_data']['Waste Details']
//               .where((trip) => DateTime.parse(trip['date_time']).toLocal().day == widget.selectedDate.day)
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load trip details');
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       print('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trip Details'),
//         backgroundColor: Color(0xFF5C964A),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _tripDetails.isEmpty
//               ? Center(child: Text('No trip details available for the selected date.'))
//               : SingleChildScrollView(
//                   child: Column(
//                     children: _tripDetails.map((trip) {
//                       return Card(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Worker Email: ${trip['worker_name']}',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Trips: ${trip['trips']}',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Quantity of Waste: ${trip['quantity_waste']} kg',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Segregated Degradable: ${trip['segregated_degradable']} kg',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Segregated Non-Degradable: ${trip['segregated_non_degradable']} kg',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Segregated Plastic: ${trip['segregated_plastic']} kg',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 'Date: ${trip['date_time']}',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//     );
//   }
// }
