// ViewComplaintsScreen.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';

// class ViewComplaintsScreen extends StatefulWidget {
//   const ViewComplaintsScreen({super.key});

//   @override
//   _ViewComplaintsScreenState createState() => _ViewComplaintsScreenState();
// }

// class _ViewComplaintsScreenState extends State<ViewComplaintsScreen>
//     with SingleTickerProviderStateMixin {
//   late String phoneNumber;
//   bool isLoading = true;
//   List<dynamic> allComplaints = [];
//   List<dynamic> pendingComplaints = [];
//   List<dynamic> resolvedComplaints = [];
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPhoneNumber();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   Future<void> _fetchPhoneNumber() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? storedPhoneNumber = prefs.getString('phone_number');

//     if (storedPhoneNumber != null) {
//       setState(() {
//         phoneNumber = storedPhoneNumber;
//         isLoading = true;
//       });
//       await _fetchComplaints(phoneNumber);
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       print("Phone number not found in session.");
//     }
//   }

//   Future<void> _fetchComplaints(String phoneNumber) async {
//     final String apiUrl =
//         'https://d029-122-172-86-111.ngrok-free.app/api/complaints?mobile_number=$phoneNumber';

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           allComplaints = data['complaints'];
//           pendingComplaints = allComplaints
//               .where((complaint) => complaint['status'] == 'Pending')
//               .toList();
//           resolvedComplaints = allComplaints
//               .where((complaint) => complaint['status'] == 'Resolved')
//               .toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         print(
//             "Failed to fetch complaints. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print("Error fetching complaints: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final double cardWidth = screenSize.width * 0.9;
//     final double cardHeight = screenSize.height * 0.4;

//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Complaint Details'),
//           backgroundColor: const Color(0xFF5C964A),
//           bottom: TabBar(
//             controller: _tabController,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white,
//             tabs: const [
//               Tab(text: 'Pending'),
//               Tab(text: 'Resolved'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             buildComplaintsList(pendingComplaints, cardWidth, cardHeight),
//             buildComplaintsList(resolvedComplaints, cardWidth, cardHeight),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildComplaintsList(
//       List complaints, double cardWidth, double cardHeight) {
//     return ListView.builder(
//       itemCount: complaints.length,
//       itemBuilder: (context, index) {
//         return complaintCard(complaints[index], cardWidth, cardHeight);
//       },
//     );
//   }

//   Widget complaintCard(
//       Map<String, dynamic> complaint, double cardWidth, double cardHeight) {
//     String formattedDate = DateFormat('dd-MM-yyyy')
//         .format(DateTime.parse(complaint['created_at']));

//     return Container(
//       width: cardWidth,
//       height: cardHeight,
//       margin: EdgeInsets.symmetric(vertical: 10, horizontal: cardWidth * 0.05),
//       clipBehavior: Clip.antiAlias,
//       decoration: ShapeDecoration(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             left: 0,
//             top: 0,
//             child: Container(
//               width: cardWidth,
//               height: cardHeight,
//               decoration: ShapeDecoration(
//                 color: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 0,
//             top: 0,
//             child: Container(
//               width: cardWidth,
//               height: cardHeight * 0.65,
//               decoration: ShapeDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage(
//                       'https://d029-122-172-86-111.ngrok-free.app${complaint['photos'][0]['image']}'),
//                   fit: BoxFit.cover,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 15,
//             top: cardHeight * 0.7,
//             child: Text(
//               '${complaint['district']}, ${complaint['gram_panchayat']}',
//               style: TextStyle(
//                 color: const Color(0xFF252525),
//                 fontSize: cardHeight * 0.05,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Positioned(
//             right: 10,
//             top: 10,
//             child: Text(
//               formattedDate,
//               style: TextStyle(
//                 color: const Color(0xFF252525),
//                 fontSize: cardHeight * 0.04,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//           Positioned(
//             left: 15,
//             top: cardHeight * 0.85,
//             child: Text(
//               complaint['caption'] ?? 'No description provided',
//               style: TextStyle(
//                 color: const Color(0xFF252525),
//                 fontSize: cardHeight * 0.045,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewComplaintsScreen extends StatefulWidget {
  const ViewComplaintsScreen({super.key});

  @override
  _ViewComplaintsScreenState createState() => _ViewComplaintsScreenState();
}

class _ViewComplaintsScreenState extends State<ViewComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late String phoneNumber;
  bool isLoading = true;
  List<dynamic> allComplaints = [];
  List<dynamic> pendingComplaints = [];
  List<dynamic> resolvedComplaints = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedPhoneNumber = prefs.getString('phone_number');

    if (storedPhoneNumber != null) {
      setState(() {
        phoneNumber = storedPhoneNumber;
        isLoading = true;
      });
      await _fetchComplaints(phoneNumber);
    } else {
      setState(() {
        isLoading = false;
      });
      print("Phone number not found in session.");
    }
  }

  Future<void> _fetchComplaints(String phoneNumber) async {
    final String apiUrl =
        'https://d029-122-172-86-111.ngrok-free.app/api/complaints?mobile_number=$phoneNumber';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          allComplaints = data['complaints'];
          pendingComplaints = allComplaints
              .where((complaint) => complaint['status'] == 'Pending')
              .toList();
          resolvedComplaints = allComplaints
              .where((complaint) => complaint['status'] == 'Resolved')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print(
            "Failed to fetch complaints. Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.9;
    final double cardHeight = screenSize.height * 0.4;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complaint Details'),
          backgroundColor: const Color(0xFF5C964A),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            buildComplaintsList(pendingComplaints, cardWidth, cardHeight),
            buildComplaintsList(resolvedComplaints, cardWidth, cardHeight),
          ],
        ),
      ),
    );
  }

  Widget buildComplaintsList(
      List complaints, double cardWidth, double cardHeight) {
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        return complaintCard(complaints[index], cardWidth, cardHeight);
      },
    );
  }

  Widget complaintCard(
      Map<String, dynamic> complaint, double cardWidth, double cardHeight) {
    String formattedDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(complaint['created_at']));

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: cardWidth * 0.05),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: cardWidth,
              height: cardHeight * 0.65,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://d029-122-172-86-111.ngrok-free.app${complaint['photos'][0]['image']}'),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: cardHeight * 0.7,
            child: Text(
              '${complaint['district']}, ${complaint['gram_panchayat']}',
              style: TextStyle(
                color: const Color(0xFF252525),
                fontSize: cardHeight * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: Text(
              formattedDate,
              style: TextStyle(
                color: const Color(0xFF252525),
                fontSize: cardHeight * 0.04,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: cardHeight * 0.85,
            child: Text(
              complaint['caption'] ?? 'No description provided',
              style: TextStyle(
                color: const Color(0xFF252525),
                fontSize: cardHeight * 0.045,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (complaint['status'] == 'Resolved')
            Positioned(
              right: 15,
              bottom: 15,
              child: TextButton(
                onPressed: () => _showResolvedPopup(complaint),
                child: Text(
                  'View Reply',
                  style: TextStyle(
                    color: Color(0xFF5C964A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Show the resolved photo in a popup
  void _showResolvedPopup(Map<String, dynamic> complaint) {
    final resolvedPhoto = complaint['resolved_photo'];
    if (resolvedPhoto != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  'https://d029-122-172-86-111.ngrok-free.app${resolvedPhoto['image']}',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
                Text(
                  'Complaint resolved successfully!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
