// authority/SMD/SMDselectRegion.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SMDselectRegion extends StatefulWidget {
  const SMDselectRegion({Key? key}) : super(key: key);

  @override
  State<SMDselectRegion> createState() => _SMDselectRegionState();
}

class _SMDselectRegionState extends State<SMDselectRegion> {
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedGramPanchayat;

  List<String> districts = [];
  List<String> blocks = [];
  List<String> gramPanchayats = [];
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  final String districtsUrl = "https://sbmgrajasthan.com/api/getDistricts";
  final String blocksUrl = "https://sbmgrajasthan.com/api/getBlocks/";
  final String gpUrl = "https://sbmgrajasthan.com/api/getGp/";

  Future<void> fetchDistricts() async {
    try {
      final response = await http.get(Uri.parse(districtsUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          districts = List<String>.from(data['districts']);
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> fetchBlocks(String selectedDistrict) async {
    try {
      final response =
          await http.get(Uri.parse('$blocksUrl?district=$selectedDistrict'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['district'] == selectedDistrict) {
          setState(() {
            blocks = List<String>.from(data['blocks']);
          });
        } else {
          throw Exception('Unexpected district returned from API');
        }
      } else {
        throw Exception('Failed to load blocks');
      }
    } catch (e) {
      print('Error fetching blocks: $e');
    }
  }

  Future<void> fetchGramPanchayats(
      String selectedDistrict, String selectedBlock) async {
        
    try {
      final response = await http.get(
          Uri.parse('$gpUrl?district=$selectedDistrict&block=$selectedBlock'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['district'] == selectedDistrict) {
          setState(() {
            gramPanchayats = List<String>.from(data['gram panchayat']);
          });
        } else {
          throw Exception('Unexpected district or block returned from API');
        }
      } else {
        throw Exception('Failed to load gram panchayats');
      }
    } catch (e) {
      print('Error fetching gram panchayats: $e');
    }
  }

  Future<void> submitSelection() async {
      String formattedDistrict = selectedDistrict?.replaceAll(' ', '_') ?? "";
      String formattedBlock = selectedBlock?.replaceAll(' ', '_') ?? "";
      String formattedGramPanchayat = selectedGramPanchayat?.replaceAll(' ', '_') ?? "";

      formattedDistrict =
          formattedDistrict.replaceAllMapped(RegExp(r'_(.)'), (match) {
        return '_${match.group(1)?.toLowerCase()}';
      });

      formattedBlock =
          formattedBlock.replaceAllMapped(RegExp(r'_(.)'), (match) {
        return '_${match.group(1)?.toLowerCase()}';
      });

      formattedGramPanchayat =
          formattedGramPanchayat.replaceAllMapped(RegExp(r'_(.)'), (match) {
        return '_${match.group(1)?.toLowerCase()}';
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('appbarselectedDistrict', formattedDistrict);
      await prefs.setString('appbarselectedBlock', formattedBlock);
      await prefs.setString('appbarselectedGramPanchayat', formattedGramPanchayat);
      Navigator.pop(context, true);
  }

  Future<void> loadSavedSelections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDistrict = prefs.getString('appbarselectedDistrict');
      selectedBlock = prefs.getString('appbarselectedBlock');
      selectedGramPanchayat = prefs.getString('appbarselectedGramPanchayat');
    });

    if (selectedDistrict != null) {
      fetchBlocks(selectedDistrict!);
    }
    if (selectedDistrict != null && selectedBlock != null) {
      fetchGramPanchayats(selectedDistrict!, selectedBlock!);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    loadSavedSelections();
    _loadLanguagePreference();
  }

  void showOptions(BuildContext context, List<String> options,
      ValueChanged<String> onSelected) {
    List<String> filteredOptions = List.from(options);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredOptions = options
                        .where((option) =>
                            option.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredOptions[index]),
                    onTap: () {
                      onSelected(filteredOptions[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                shadows: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 6,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 125,
                    child: Text(
                      'Currently, you are viewing Gram Panchayat-level data. Reset to view block level data.',
                      style: TextStyle(
                        color: const Color(0xFF49454F),
                        fontSize: 8,
                        fontFamily: 'Nunito Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFEF4F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(83),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove('appbarselectedGramPanchayat');
                        await prefs.remove('appbarselectedBlock');
                        await prefs.remove('appbarselectedDistrict');
                        setState(() {
                          selectedGramPanchayat = null;
                          selectedBlock = null;
                          selectedDistrict = null;
                        });
                        Navigator.pop(context, true);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Reset',
                            style: TextStyle(
                              color: const Color(0xFFB3261E),
                              fontSize: 14,
                              fontFamily: 'Nunito Sans',
                              fontWeight: FontWeight.w500,
                              height: 1.43,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('District', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () {
                showOptions(context, districts, (value) {
                  setState(() {
                    selectedDistrict = value;
                    selectedBlock = null; // Reset dependent fields
                    selectedGramPanchayat = null;
                  });
                  fetchBlocks(value);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.grey,
                    ),
                    Text(selectedDistrict ?? 'Select District'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Block', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () {
                if (selectedDistrict != null) {
                  showOptions(context, blocks, (value) {
                    setState(() {
                      selectedBlock = value;
                      selectedGramPanchayat = null; // Reset dependent fields
                    });
                    fetchGramPanchayats(selectedDistrict!, value);
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.grey,
                    ),
                    Text(selectedBlock ?? 'Select Block'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Gram Panchayat', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () {
                if (selectedBlock != null) {
                  showOptions(context, gramPanchayats, (value) {
                    setState(() {
                      selectedGramPanchayat = value;
                    });
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.grey,
                    ),
                    Text(selectedGramPanchayat ?? 'Select Gram Panchayat'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5C964A),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
