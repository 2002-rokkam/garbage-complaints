// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/OnboardingAnimation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CitizensScreen/CitizensScreen.dart';
import 'WokersScreen/WorkerScreen.dart';
import 'authority/BDO/BDOScreen.dart';
import 'authority/CEO/CEOScreen.dart';
import 'authority/SMD/SMDScreen.dart';
import 'authority/VDO/VDOScreen.dart';
import 'firebase_options.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  String? languageCode = prefs.getString('language') ?? 'en';

  runApp(MyApp(
      token: token,
      userId: userId,
      position: position,
      locale: Locale(languageCode)));
}

class MyApp extends StatefulWidget {
  final String? token;
  final String? userId;
  final String? position;
  final Locale locale;

  const MyApp(
      {Key? key, this.token, this.userId, this.position, required this.locale})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void _changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;

    if (widget.token != null) {
      home = CitizensScreen();
    } else if (widget.userId != null && widget.position != null) {
      home = determinePageBasedOnPosition(widget.position);
    } else {
      home = OnboardingAnimation(changeLanguage: _changeLanguage);
    }

    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      case 'Smd':
        return SMDScreen();
      default:
        return OnboardingAnimation(changeLanguage: _changeLanguage);
    }
  }
}