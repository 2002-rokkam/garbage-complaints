// CustomScreen.dart
// import 'package:flutter/material.dart';
// import 'dart:async';

// class CustomScreen extends StatefulWidget {
//   @override
//   _CustomScreenState createState() => _CustomScreenState();
// }

// class _CustomScreenState extends State<CustomScreen> {
//   final PageController _pageController = PageController();

//   @override
//   void initState() {
//     super.initState();
//     // Auto-scroll images
//     Future.delayed(Duration.zero, () {
//       Timer.periodic(const Duration(seconds: 3), (Timer timer) {
//         if (_pageController.hasClients) {
//           int nextPage = _pageController.page!.toInt() + 1;
//           _pageController.animateToPage(
//             nextPage % 3,
//             duration: const Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(
//             0xFF5C964A), // Sets the AppBar background color to green
//         flexibleSpace: Container(
//           height: 100,
//         ),
//       ),
//       body: Column(
//         children: [
//           // AppBar extending to the image start
//           Container(
//             height: 200,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF5C964A), // Green
//                   Colors.white, // White
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 stops: [0.5, 0.5], // Half green and half white
//               ),
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             child: Stack(
//               children: [
//                 Positioned(
//                   bottom: 50,
//                   left: 16,
//                   right: 16,
//                   child: Container(
//                     height: 150,
//                     child: PageView(
//                       controller: _pageController,
//                       children: [
//                         _buildImageContainer(
//                             'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
//                         _buildImageContainer(
//                             'https://europe1.discourse-cdn.com/figma/original/3X/7/1/7105e9c010b3d1f0ea893ed5ca3bd58e6cec090e.gif'),
//                         _buildImageContainer(
//                             'https://gifyard.com/wp-content/uploads/2023/01/girl-laughs.gif'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Button Grid
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildButton('Door to Door', context, 'DoorToDoorScreen'),
//                   _buildButton('Road Sweeping', context, 'RoadSweepingScreen'),
//                   _buildButton(
//                       'Drain Cleaning', context, 'DrainCleaningScreen'),
//                   _buildButton('CSC', context, 'CSCScreen'),
//                   _buildButton('RRC', context, 'RRCScreen'),
//                   _buildButton('Wages', context, 'WagesScreen'),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageContainer(String imageUrl) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: NetworkImage(imageUrl),
//           fit: BoxFit.cover,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//     );
//   }

//   Widget _buildButton(String label, BuildContext context, String routeName) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => _getPage(routeName),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 16,
//               offset: const Offset(0, 8),
//             ),
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 0),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Color(0xFF6B6B6B),
//               fontSize: 16,
//               fontFamily: 'Nunito Sans',
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _getPage(String routeName) {
//     switch (routeName) {
//       case 'DoorToDoorScreen':
//         return DoorToDoorScreen();
//       case 'RoadSweepingScreen':
//         return RoadSweepingScreen();
//       case 'DrainCleaningScreen':
//         return DrainCleaningScreen();
//       case 'CSCScreen':
//         return CSCScreen();
//       case 'RRCScreen':
//         return RRCScreen();
//       case 'WagesScreen':
//         return WagesScreen();
//       default:
//         return Scaffold(body: Center(child: Text('Page not found')));
//     }
//   }
// }

// class DoorToDoorScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('Door to Door Screen')));
//   }
// }

// class RoadSweepingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('Road Sweeping Screen')));
//   }
// }

// class DrainCleaningScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('Drain Cleaning Screen')));
//   }
// }

// class CSCScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('CSC Screen')));
//   }
// }

// class RRCScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('RRC Screen')));
//   }
// }

// class WagesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Text('Wages Screen')));
//   }
// }
import 'package:flutter/material.dart';
import 'dart:async';

import 'authority/CSCSectionScreen.dart';
import 'authority/CustomScreen.dart';

// Placeholder screen widgets for navigation (add actual screen widgets)
class DoorToDoorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Door to Door Screen')));
  }
}

class RoadSweepingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Road Sweeping Screen')));
  }
}

class DrainCleaningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Drain Cleaning Screen')));
  }
}

class CSCScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('CSC Screen')));
  }
}

class RRCScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('RRC Screen')));
  }
}

class WagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Wages Screen')));
  }
}

class CustomScreen extends StatefulWidget {
  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final PageController _pageController = PageController();

  // List of items for the buttons, with label and image URL
  final List<Map<String, String>> buttonItems = [
    {
      'label': 'Door to Door',
      'imageUrl': 'images/d2d.png',
      'route': 'DoorToDoorScreen'
    },
    {
      'label': 'Road Sweeping',
      'imageUrl': 'images/road_sweeping.png',
      'route': 'RoadSweepingScreen'
    },
    {
      'label': 'Drain Cleaning',
      'imageUrl': 'images/drainage_collectin.png',
      'route': 'DrainCleaningScreen'
    },
    {'label': 'CSC', 'imageUrl': 'images/CSC.png', 'route': 'CSCScreen'},
    {'label': 'RRC', 'imageUrl': 'images/wages.png', 'route': 'RRCScreen'},
    {'label': 'Wages', 'imageUrl': 'images/wages.png', 'route': 'WagesScreen'},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll images
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (_pageController.hasClients) {
          int nextPage = _pageController.page!.toInt() + 1;
          _pageController.animateToPage(
            nextPage % 3,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C964A),
        flexibleSpace: Container(
          height: 100,
        ),
      ),
      body: Column(
        children: [
          // AppBar extending to the image start
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5C964A), // Green
                  Color.fromRGBO(239, 239, 239, 1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 0.5],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 50,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 150,
                    child: PageView(
                      controller: _pageController,
                      children: [
                        _buildImageContainer(
                            'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
                        _buildImageContainer(
                            'https://europe1.discourse-cdn.com/figma/original/3X/7/1/7105e9c010b3d1f0ea893ed5ca3bd58e6cec090e.gif'),
                        _buildImageContainer(
                            'https://gifyard.com/wp-content/uploads/2023/01/girl-laughs.gif'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Dynamic Button Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: buttonItems.length,
                itemBuilder: (context, index) {
                  final item = buttonItems[index];
                  return _buildButton(item['label']!, item['imageUrl']!,
                      item['route']!, context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Image container for the PageView
  Widget _buildImageContainer(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Button widget with dynamic label, image, and navigation
  Widget _buildButton(
      String label, String imageUrl, String routeName, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _getPage(routeName),
          ),
        );
      },
      child: Container(
        width: 120, // Adjusted width
        height: 80, // Adjusted height
        padding: const EdgeInsets.all(12), // Adjusted padding
        margin: const EdgeInsets.symmetric(
            horizontal: 8), // Added margin from left and right
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          // Move label to bottom
          children: [
            Container(
              width: 51,
              height: 62,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Image.asset(
                imageUrl, // Load from local assets
                fit: BoxFit.cover,
              ),
            ),
            // Adjust the label placement here
            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.start, // Center-align the label
                style: const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 14, // Smaller font size
                  fontFamily: 'Nunito Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPage(String routeName) {
    switch (routeName) {
      case 'DoorToDoorScreen':
        return ResponsiveScreen();
      case 'RoadSweepingScreen':
        return RoadSweepingScreen();
      case 'DrainCleaningScreen':
        return DrainCleaningScreen();
      case 'CSCScreen':
        return CSCSectionScreen();
      case 'RRCScreen':
        return RRCScreen();
      case 'WagesScreen':
        return WagesScreen();
      default:
        return Scaffold(body: Center(child: Text('Page not found')));
    }
  }
}
