// OfficeLoginScreen.dart
// import 'package:flutter/material.dart';

// import 'authority/CSCSectionScreen.dart';
// import 'authority/ComplaintsSectionScreen.dart';
// import 'authority/D2DSectionScreen.dart';
// import 'authority/DrainCleaningSectionScreen.dart';
// import 'authority/RRCSectionScreen.dart';
// import 'authority/RoadSweepingScreen.dart';
// import 'authority/WagesSectionScreen.dart';

// class OfficeLoginScreen extends StatelessWidget {
//   const OfficeLoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Office Login"),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           _buildSectionCard(
//               context, "D2D", Icons.directions, D2DSectionScreen()),
//           _buildSectionCard(
//               context, "Road Sweeping", Icons.directions, RoadSweepingScreen()),
//           _buildSectionCard(context, "Drain Cleaning", Icons.cleaning_services,
//               DrainCleaningSectionScreen()),
//           _buildSectionCard(context, "CSC", Icons.place, CSCSectionScreen()),
//           _buildSectionCard(context, "RRC", Icons.delete, RRCSectionScreen()),
//           _buildSectionCard(
//               context, "Wages", Icons.money, WagesSectionScreen()),
//           _buildSectionCard(
//               context, "Complaints", Icons.report, ComplaintsSectionScreen()),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionCard(
//       BuildContext context, String title, IconData icon, Widget targetScreen) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => targetScreen),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import 'authority/CSCSectionScreen.dart';
import 'authority/ComplaintsSectionScreen.dart';
import 'authority/D2DSectionScreen.dart';
import 'authority/DrainCleaningSectionScreen.dart';
import 'authority/RRCSectionScreen.dart';
import 'authority/RoadSweepingScreen.dart';
import 'authority/WagesSectionScreen.dart';

class OfficeLoginScreen extends StatelessWidget {
  const OfficeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Office Login"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two tiles per row
          crossAxisSpacing: 16, // Space between columns
          mainAxisSpacing: 16, // Space between rows
          childAspectRatio: 1, // Square tiles
        ),
        padding: const EdgeInsets.all(16.0),
        itemCount: 7, // Number of items in the grid
        itemBuilder: (context, index) {
          return _buildSectionCard(context, index);
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, int index) {
    List<String> titles = [
      "D2D",
      "Road Sweeping",
      "Drain Cleaning",
      "CSC",
      "RRC",
      "Wages",
      "Complaints"
    ];

    List<IconData> icons = [
      Icons.directions,
      Icons.directions,
      Icons.cleaning_services,
      Icons.place,
      Icons.delete,
      Icons.money,
      Icons.report,
    ];

    List<Widget> screens = [
      D2DSectionScreen(),
      RoadSweepingScreen(),
      DrainCleaningSectionScreen(),
      WagesSectionScreen(),
      ComplaintsSectionScreen(),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screens[index]),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icons[index],
              color: Colors.blue,
              size: 48, // Bigger icon
            ),
            const SizedBox(height: 8),
            Text(
              titles[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
