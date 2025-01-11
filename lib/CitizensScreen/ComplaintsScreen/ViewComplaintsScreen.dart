// CitizensScreen/ComplaintsScreen/ViewComplaintsScreen.dart
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
  bool isLoading = true;
  List<dynamic> allComplaints = [];
  List<dynamic> pendingComplaints = [];
  List<dynamic> resolvedComplaints = [];
  late TabController _tabController;
  late String _idToken;

  @override
  void initState() {
    super.initState();
    _loadTokenFromSharedPrefs(); // Load the token and then fetch complaints
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadTokenFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? idToken = prefs.getString('id_token');
    if (idToken != null) {
      setState(() {
        _idToken = idToken;
      });
      _fetchComplaints(); // Fetch complaints after token is loaded
    } else {
      // Handle missing token (e.g., redirect to login screen)
      throw 'Token not found. Please log in again.';
    }
  }

 Future<void> _fetchComplaints() async {
    final String apiUrl =
        'https://c035-122-172-86-134.ngrok-free.app/api/complaints';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'token $_idToken',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          allComplaints = data['complaints'];
          // Sort complaints by created_at in descending order
          allComplaints.sort((a, b) => DateTime.parse(b['created_at'])
              .compareTo(DateTime.parse(a['created_at'])));
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
    final double cardWidth = screenSize.width * 0.98;
    final double cardHeight = screenSize.height * 0.3;

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
        backgroundColor: Color.fromRGBO(239, 239, 239, 1),
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
                  image: NetworkImage('${complaint['photos'][0]['image']}'),
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
            right: 15,
            top: 10, // Adjusted to make room for the date container
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: const Color(0xFF252525),
                  fontSize: cardHeight * 0.04,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: cardHeight * 0.80,
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
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rounded corners
            ),
            elevation: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background for the card
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(16), // Rounded image corners
                    child: Image.network(
                      '${resolvedPhoto['image']}',
                      height: 250,
                      width: double.infinity, // Make the image responsive
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Complaint Resolved Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Stylish button color
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
