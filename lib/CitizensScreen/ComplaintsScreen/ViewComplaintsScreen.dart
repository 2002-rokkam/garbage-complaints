// CitizensScreen/ComplaintsScreen/ViewComplaintsScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    _loadTokenFromSharedPrefs();
    _tabController = TabController(length: 2, vsync: this);
    _loadLanguagePreference();
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
      throw 'Token not found. Please log in again.';
    }
  }

  Future<void> _fetchComplaints() async {
    final String apiUrl = 'https://sbmgrajasthan.com/api/complaints';
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
              .where((complaint) =>
                  complaint['status'] == 'Pending' ||
                  complaint['status'] == 'Resolved')
              .toList();

          resolvedComplaints = allComplaints
              .where((complaint) => complaint['status'] == 'Verified')
              .toList();

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
            indicatorColor: Color.fromRGBO(255, 210, 98, 1),
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: localizations.pending),
              Tab(text: localizations.resolved),
            ],
          ),
        ),
        backgroundColor: Color.fromRGBO(239, 239, 239, 1),
        body: isLoading
            ? Center(
                child: Image.asset(
                  'assets/images/Loder.gif', // Your GIF path in assets
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
    final localizations = AppLocalizations.of(context)!;
    if (complaints.isEmpty) {
      return Center(
        child: Text(localizations.noComplaints),
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
    List<dynamic> images = complaint['photos'];
    final PageController _pageController = PageController();
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showFullScreenImage(images[index]['image']);
                        },
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/setting-loder.gif',
                          image: images[index]['image'],
                          fit: BoxFit.cover,
                          height: 150,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: images.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.black,
                        dotHeight: 6,
                        dotWidth: 6,
                        expansionFactor: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              '${complaint['district']}, ${complaint['gram_panchayat']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              utf8.decode(complaint['caption'].toString().codeUnits) ??
                  'No description provided',
            ),
            trailing: Text(formattedDate),
          ),
          if (complaint['status'] == 'Resolved')
            TextButton(
              onPressed: () => _showResolvedPopup(complaint),
              child: Text(
                localizations.viewReply,
                style: TextStyle(
                  color: Color(0xFF5C964A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: Image.asset(
                        'assets/images/Loder.gif',
                        width: 200,
                        height: 200,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
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
                      backgroundColor: Colors.green,
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
