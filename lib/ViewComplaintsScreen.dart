// ViewComplaintsScreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // To format the date


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

  // Fetch the phone number from SharedPreferences and then fetch complaints
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

  // Fetch complaints from the API
  Future<void> _fetchComplaints(String phoneNumber) async {
    final String apiUrl =
        'https://3720-223-185-51-171.ngrok-free.app/api/complaints?mobile_number=$phoneNumber';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          allComplaints = data['complaints'];
          // Filter complaints into Pending and Resolved lists
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Complaint Details'),
          backgroundColor: const Color(0xFF5C964A), // Sets the background color to green
          bottom: TabBar(
            labelColor: Colors
                .white, // Sets the text color for the selected tab to white
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Complaints Tab
            ListView.builder(
              itemCount: allComplaints.length,
              itemBuilder: (context, index) {
                if (allComplaints[index]['status'] == 'Pending') {
                  return complaintCard(allComplaints[index]);
                }
                return SizedBox.shrink(); // Empty widget for other statuses
              },
            ),
            // Resolved Complaints Tab (Add logic for resolved status here)
            ListView.builder(
              itemCount: allComplaints.length,
              itemBuilder: (context, index) {
                if (allComplaints[index]['status'] == 'Resolved') {
                  return complaintCard(allComplaints[index]);
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget complaintCard(Map<String, dynamic> complaint) {
    // Format the date
    String formattedDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(complaint['created_at']));

    return Container(
      width: 370,
      height: 291,
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
              width: 370,
              height: 291,
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
              width: 370,
              height: 188.59,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(complaint['photos'][0]
                      ['image']), // Use the first image as the background
                  fit: BoxFit.fill,
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
            left: 15.39,
            top: 204,
            child: Container(
              width: 16,
              height: 16,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: FlutterLogo(),
            ),
          ),
          Positioned(
            left: 40,
            top: 202.50,
            child: Text(
              '${complaint['district']}, ${complaint['gram_panchayat']}',
              style: TextStyle(
                color: Color(0xFF252525),
                fontSize: 16,
                fontFamily: 'Nunito Sans',
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
                color: Color(0xFF252525),
                fontSize: 14,
                fontFamily: 'Nunito Sans',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            left: 13,
            top: 237.50,
            child: Divider(
              color: Colors.black.withOpacity(0.1),
              thickness: 1,
              indent: 15,
              endIndent: 15,
            ),
          ),
          Positioned(
            left: 15.39,
            top: 250.01,
            child: Text(
              complaint['caption'] ?? 'No description provided',
              style: TextStyle(
                color: Color(0xFF252525),
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
