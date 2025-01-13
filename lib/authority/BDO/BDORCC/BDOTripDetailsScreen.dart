// authority/BDO/BDOTripDetailsScreen.dart
import 'package:flutter/material.dart';

class BDOTripDetailsScreen extends StatelessWidget {
  final List tripDetails;

  const BDOTripDetailsScreen({Key? key, required this.tripDetails})
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
