// authority/BDO/BDOD2D/QRDetailsScreen.dart
import 'package:flutter/material.dart';
 import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRDetailsScreen extends StatefulWidget {
  final List tripDetails;

  const QRDetailsScreen({Key? key, required this.tripDetails})
      : super(key: key);

  @override
  _QRDetailsScreenState createState() => _QRDetailsScreenState();
}

class _QRDetailsScreenState extends State<QRDetailsScreen> {
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
    _loadLanguagePreference();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.qrDetails),
        backgroundColor: const Color(0xFF5C964A),
      ),
      backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: widget.tripDetails.isEmpty
            ? Center(
                child: Text(localizations.noTripDetails),
              )
            : Column(
                children: widget.tripDetails.map((trip) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${localizations.qrScannedData} ${trip['QRAddress']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${trip['date_time']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
