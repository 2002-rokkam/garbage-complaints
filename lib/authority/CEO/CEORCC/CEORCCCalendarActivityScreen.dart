// authority/CEO/CEORCC/CEORCCCalendarActivityScreen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../BDO/BDORCC/BDOTripDetailsScreen.dart';
import '../../BDO/BDORCC/RCCBeforeAfterScreen.dart';

class CEORCCCalendarActivityScreen extends StatefulWidget {
  final String section;
  final String district;
  final String block;
  final String gramPanchayat;

  const CEORCCCalendarActivityScreen({
    Key? key,
    required this.section,
    required this.district,
    required this.block,
    required this.gramPanchayat,
  }) : super(key: key);

  @override
  _CEORCCCalendarActivityScreenState createState() =>
      _CEORCCCalendarActivityScreenState();
}

class _CEORCCCalendarActivityScreenState
    extends State<CEORCCCalendarActivityScreen>
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
            'https://c035-122-172-86-134.ngrok-free.app/api/bdo-section-dashboard')
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
            'https://c035-122-172-86-134.ngrok-free.app/api/bdo-section-dashboard')
        .replace(queryParameters: {
      'worker_id': workerId,
      'section': 'Waste Details',
      'district': widget.district,
      'gram_panchayat': widget.gramPanchayat,
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
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Column(
        children: [
          Container(
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
          Container(
              height: 80,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : selectedActivities.isEmpty
                      ? Center(child: Text('No activities for selected date.'))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            Card(
                              color: Color.fromRGBO(239, 239, 239, 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center vertically
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .centerLeft, // Align text to the left
                                      child: Text(
                                        'Total Activities: ${selectedActivities.length}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment
                                        .centerRight, // Align button to the right
                                    child: TextButton(
                                      onPressed: () {
                                        if (_tabController.index == 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RCCBeforeAfterScreen(
                                                activities: selectedActivities,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BDOTripDetailsScreen(
                                                tripDetails: _tripDetails,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors
                                            .green, // Set the background color to green
                                      ),
                                      child: Text(
                                        'View All',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              color: Color.fromRGBO(239, 239, 239, 1),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center vertically
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment
                                          .centerLeft, // Align text to the left
                                      child: Text(
                                        'Total Trip Details: ${_tripDetails.length}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment
                                        .centerRight, // Align button to the right
                                    child: TextButton(
                                      onPressed: () {
                                        if (_tabController.index == 0) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RCCBeforeAfterScreen(
                                                activities: selectedActivities,
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BDOTripDetailsScreen(
                                                tripDetails: _tripDetails,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors
                                            .green, // Set the background color to green
                                      ),
                                      child: Text(
                                        'View All',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
        ],
      ),
    );
  }
}

// class TripDetailsScreen extends StatelessWidget {
//   final List tripDetails;

//   const TripDetailsScreen({Key? key, required this.tripDetails})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trip Details'),
//         backgroundColor: Color(0xFF5C964A),
//       ),
//       body: tripDetails.isEmpty
//           ? Center(
//               child: Text('No trip details available for the selected date.'))
//           : SingleChildScrollView(
//               child: Column(
//                 children: tripDetails.map((trip) {
//                   return Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Worker Email: ${trip['worker_name']}',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Trips: ${trip['trips']}',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Quantity of Waste: ${trip['quantity_waste']} kg',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Segregated Degradable: ${trip['segregated_degradable']} kg',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Segregated Non-Degradable: ${trip['segregated_non_degradable']} kg',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Segregated Plastic: ${trip['segregated_plastic']} kg',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                             ),
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Date: ${trip['date_time']}',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//     );
//   }
// }

// class BeforeAfterScreen extends StatelessWidget {
//   final List activities;

//   const BeforeAfterScreen({Key? key, required this.activities})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Before & After'),
//         backgroundColor: Color(0xFF5C964A),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: activities.map((activity) {
//             return Card(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: Color(0xFFFFD262),
//                     width: 1,
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 width: 40.42,
//                                 height: 40.42,
//                                 decoration: ShapeDecoration(
//                                   color: Color(0xFFFFF2C6),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(59),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 10, vertical: 5),
//                                 decoration: ShapeDecoration(
//                                   color: (activity['status'] ?? 'Pending') ==
//                                           'Completed'
//                                       ? Color(0xFF5C964A)
//                                       : Color(0xFFFFA726),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(18),
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     activity['status'] ?? 'Pending',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             width: 120,
//                             height: 26,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 5),
//                             decoration: ShapeDecoration(
//                               color: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(26),
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 activity['date_time'] ?? 'N/A',
//                                 style: TextStyle(
//                                   color: Color(0xFF252525),
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Container(
//                             width: 150.10,
//                             height: 99.52,
//                             decoration: ShapeDecoration(
//                               image: DecorationImage(
//                                 image:
//                                     NetworkImage('${activity['before_image']}'),
//                                 fit: BoxFit.cover,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             width: 150.10,
//                             height: 99.52,
//                             decoration: ShapeDecoration(
//                               image: DecorationImage(
//                                 image:
//                                     NetworkImage('${activity['after_image']}'),
//                                 fit: BoxFit.cover,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Wrap(
//                         children: [
//                           Text(
//                             '${activity['address']} \nWorked by: ${activity['worker_name']}',
//                             style: TextStyle(
//                               color: Color(0xFF252525),
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
