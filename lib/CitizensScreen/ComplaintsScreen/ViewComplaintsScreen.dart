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
    _loadTokenFromSharedPrefs();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _loadTokenFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String? idToken = prefs.getString('id_token');
    if (idToken != null) {
      setState(() {
        _idToken = idToken;
      });
      _fetchComplaints();
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
        body: isLoading
           ? Center(
                child: Image.asset(
                  'images/Loder.gif', // Your GIF path in assets
                  width: 200, // Adjust the size as needed
                  height: 200,
                ),
              )
            
            : TabBarView(
                controller: _tabController,
                children: [
                  buildComplaintsList(pendingComplaints),
                  buildComplaintsList(resolvedComplaints),
                ],
              ),
      ),
    );
  }

  Widget buildComplaintsList(List complaints) {
    if (complaints.isEmpty) {
      return Center(
        child: Text('No complaints available.'),
      );
    }
    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        return complaintCard(complaints[index]);
      },
    );
  }

  Widget complaintCard(Map<String, dynamic> complaint) {
    String formattedDate = DateFormat('dd-MM-yyyy')
        .format(DateTime.parse(complaint['created_at']));

    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: FadeInImage.assetNetwork(
              placeholder: 'images/setting-loder.gif', // Add a loader image in assets
              image: '${complaint['photos'][0]['image']}',
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
            ),
          ),
          ListTile(
            title: Text(
              '${complaint['district']}, ${complaint['gram_panchayat']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              complaint['caption'] ?? 'No description provided',
            ),
            trailing: Text(formattedDate),
          ),
          if (complaint['status'] == 'Resolved')
            TextButton(
              onPressed: () => _showResolvedPopup(complaint),
              child: Text('View Reply', style: TextStyle(
                                     color: Color(0xFF5C964A),
                     fontWeight: FontWeight.bold,
               ),
                ),
            ),
        ],
      ),
    );
  }

  void _showResolvedPopup(Map<String, dynamic> complaint) {
    final resolvedPhoto = complaint['resolved_photo'];
    if (resolvedPhoto != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      '${resolvedPhoto['image']}',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Complaint Resolved Successfully!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      primary:
                          Colors.green, // Set the background color to green
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
