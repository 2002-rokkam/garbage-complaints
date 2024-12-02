import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthorityLoginScreen extends StatefulWidget {
  const AuthorityLoginScreen({super.key});

  @override
  _AuthorityLoginScreenState createState() => _AuthorityLoginScreenState();
}

class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("File Complaint / Feedback"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Displaying complaints
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No complaints found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Display complaints
                final complaints = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    final data = complaint.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          "District: ${data['district'] ?? 'Unknown'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Gram Panchayat: ${data['gram_panchayat'] ?? 'Unknown'}",
                            ),
                            const SizedBox(height: 4),
                            if (data['photos'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List<Widget>.from((data['photos'] as List)
                                    .map((photo) => Text(
                                          "Photo Caption: ${photo['caption']}, "
                                          "Location: (${photo['latitude']}, ${photo['longitude']})",
                                        ))),
                              ),
                          ],
                        ),
                        trailing: Text(
                          data['timestamp'] != null
                              ? (data['timestamp'] as Timestamp)
                                  .toDate()
                                  .toString()
                              : "No timestamp",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Refresh button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Data"),
            ),
          ),
        ],
      ),
    );
  }
}
