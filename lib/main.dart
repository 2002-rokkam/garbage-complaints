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
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'Login/PhoneAuthScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

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
      home = CitizensScreen(); 
    } else if (userId != null && position != null) {
      home =
          determinePageBasedOnPosition(position); 
    } else {
      home = PhoneInputScreen(); 
    }

    return MaterialApp(
      home: home,
    );
  }

  Widget determinePageBasedOnPosition(String? position) {
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
        return PhoneInputScreen();
    }
  }
}