// authority/BDO/contractorDetails.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Contractordetails extends StatefulWidget {
  final String gramPanchayat;

  const Contractordetails({Key? key, required this.gramPanchayat})
      : super(key: key);

  @override
  State<Contractordetails> createState() => _ContractordetailsState();
}

class _ContractordetailsState extends State<Contractordetails> {
  late Future<List<Map<String, dynamic>>> contractorDetails;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    contractorDetails = fetchContractorDetails();
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<List<Map<String, dynamic>>> fetchContractorDetails() async {
    final apiUrl =
        'https://sbmgrajasthan.com/api/contractors/?gp=${widget.gramPanchayat}';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['contractors']);
    } else {
      throw Exception('No contractor details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.contractorDetails,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5C964A),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
        future: contractorDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset(
                'assets/images/Loder.gif',
                width: 200,
                height: 200,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadData),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noDataAvailable),
            );
          }
          final contractors = snapshot.data;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contractors!.length,
            itemBuilder: (context, index) {
              return _buildContractorsCard(context, contractors[index]);
            },
          );
        },
      ),
    );
  }
}

String capitalizeFirstLetter(String text) {
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return word;
  }).join(' ');
}

Widget _buildContractorsCard(
    BuildContext context, Map<String, dynamic> contractor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 2))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          contractor.entries.where((entry) => entry.key != 'id').map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!
                    .capitalizeFirstLetter(entry.key.replaceAll('_', ' ')),
                style: const TextStyle(
                    fontSize: 16, color: Color.fromRGBO(107, 107, 107, 0.5)),
              ),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                    fontSize: 16, color: Color.fromRGBO(107, 107, 107, 1)),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
