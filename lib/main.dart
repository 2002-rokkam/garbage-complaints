// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CitizensScreen/CitizensScreen.dart';
import 'WokersScreen/WorkerScreen.dart';
import 'authority/BDO/BDOScreen.dart';
import 'authority/CEO/CEOScreen.dart';
import 'authority/VDO/VDOScreen.dart';
import 'onBoardingPage1.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );  
  final prefs = await SharedPreferences.getInstance();

  String? token = prefs.getString('id_token');
  String? userId = prefs.getString('worker_id');
  String? position = prefs.getString('position');

  runApp(MyApp(token: token, userId: userId, position: position));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? userId;
  final String? position;

  MyApp({this.token, this.userId, this.position});

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (token != null) {
      home = CitizensScreen(); // Navigate to customer home
    } else if (userId != null && position != null) {
      home =
          determinePageBasedOnPosition(position); // Navigate based on position
    } else {
      home = OnboardingScreen(); // Default to login
    }

    return MaterialApp(
      home: home,
    );
  }

  Widget determinePageBasedOnPosition(String? position) {
    // Map position to the respective screen
    switch (position) {
      case 'Worker':
        return WorkerScreen();
      case 'Vdo':
        return VDOScreen();
      case 'Bdo':
        return BDOScreen();
      case 'Ceo':
        return CEOScreen();
      case 'Aceo':
        return CEOScreen();
      default:
        return OnboardingScreen();
    }
  }
}