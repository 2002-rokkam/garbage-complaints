// authority/VDO/VDOCalendarActivityScreen.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class VDOCalendarActivityScreen extends StatefulWidget {
//   final String section;

//   const VDOCalendarActivityScreen({Key? key, required this.section})
//       : super(key: key);

//   @override
//   _VDOCalendarActivityScreenState createState() =>
//       _VDOCalendarActivityScreenState();
// }

// class _VDOCalendarActivityScreenState extends State<VDOCalendarActivityScreen> {
//   DateTime _selectedDate = DateTime.now();
//   List _activities = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchActivities();
//   }

//   Future<String> getWorkerId() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String workerId = prefs.getString('worker_id') ?? "";
//     return workerId;
//   }

//   Future<void> fetchActivities() async {
//     String workerId = await getWorkerId();
//   print(workerId);
//     setState(() {
//       _isLoading = true;
//     });

//     // Construct the URL with the workerId parameter
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
//           // Activities List
//           Expanded(
//             child: _isLoading
//                 ? Center(child: CircularProgressIndicator())
//                 : selectedActivities.isEmpty
//                     ? Center(child: Text('No activities for selected date.'))
//                     : SingleChildScrollView(
//                         child: Column(
//                           children: selectedActivities.map((activity) {
//                             return Card(
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: Color(0xFFFFD262),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize
//                                         .min, // This allows the container to grow based on content
//                                     children: [
//                                       // Top Row: Logo, Status, and Date-Time
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Container(
//                                                 width: 40.42,
//                                                 height: 40.42,
//                                                 decoration: ShapeDecoration(
//                                                   color: Color(0xFFFFF2C6),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             59),
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(width: 8),
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 10,
//                                                         vertical: 5),
//                                                 decoration: ShapeDecoration(
//                                                   color: (activity['status'] ??
//                                                               'Pending') ==
//                                                           'Completed'
//                                                       ? Color(0xFF5C964A)
//                                                       : Color(0xFFFFA726),
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             18),
//                                                   ),
//                                                 ),
//                                                 child: Center(
//                                                   child: Text(
//                                                     activity['status'] ??
//                                                         'Pending',
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 12,
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           Container(
//                                             width: 120,
//                                             height: 26,
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 10, vertical: 5),
//                                             decoration: ShapeDecoration(
//                                               color: Colors.white,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(26),
//                                               ),
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 activity['date_time'] ?? 'N/A',
//                                                 style: TextStyle(
//                                                   color: Color(0xFF252525),
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 8),
//                                       // Before and After Images
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           Container(
//                                             width: 150.10,
//                                             height: 99.52,
//                                             decoration: ShapeDecoration(
//                                               image: DecorationImage(
//                                                 image: NetworkImage(
//                                                   '${activity['before_image']}',
//                                                 ),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 150.10,
//                                             height: 99.52,
//                                             decoration: ShapeDecoration(
//                                               image: DecorationImage(
//                                                 image: NetworkImage(
//                                                   '${activity['after_image']}',
//                                                 ),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(height: 8),
//                                       // Address and Worker Email
//                                       Wrap(
//                                         children: [
//                                           Text(
//                                             '${activity['address']} \nWorked by: ${activity['worker_name']}',
//                                             style: TextStyle(
//                                               color: Color(0xFF252525),
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// authority/VDOCalendarActivityScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VDOCalendarActivityScreen extends StatefulWidget {
  final String section;

  const VDOCalendarActivityScreen({Key? key, required this.section})
      : super(key: key);

  @override
  _VDOCalendarActivityScreenState createState() =>
      _VDOCalendarActivityScreenState();
}

class _VDOCalendarActivityScreenState extends State<VDOCalendarActivityScreen> {
  DateTime _selectedDate = DateTime.now();
  List _activities = [];

  @override
  void initState() {
    super.initState();
    fetchActivities();
  }

  Future<String> getWorkerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? "";
  }

  Future<void> fetchActivities() async {
    String workerId = await getWorkerId();
    setState(() {
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
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Complaints: ${selectedActivities.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectedDateActivitiesScreen(
                            selectedDate: _selectedDate,
                            activities: selectedActivities,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF5C964A), // Button color
                    ),
                    child: Text('View Complaints'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// authority/SelectedDateActivitiesScreen.dart
// authority/SelectedDateActivitiesScreen.dart
class SelectedDateActivitiesScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List activities;

  const SelectedDateActivitiesScreen({
    Key? key,
    required this.selectedDate,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Activities on ${selectedDate.toLocal().toString().split(' ')[0]}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF5C964A),
      ),
      body: activities.isEmpty
          ? Center(child: Text('No activities for selected date.'))
          : SingleChildScrollView(
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
                                        color: (activity['status'] ?? 'Pending') == 'Completed'
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
                                      image: NetworkImage(
                                        '${activity['before_image']}',
                                      ),
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
                                      image: NetworkImage(
                                        '${activity['after_image']}',
                                      ),
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
