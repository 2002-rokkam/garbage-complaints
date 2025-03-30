// authority/CEO/CEOselectRegion.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CEOselectRegion extends StatefulWidget {
  const CEOselectRegion({Key? key}) : super(key: key);

  @override
  State<CEOselectRegion> createState() => _CEOselectRegionState();
}

class _CEOselectRegionState extends State<CEOselectRegion> {
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedGramPanchayat;
  late Locale _locale;

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  List<String> districts = [];
  List<String> blocks = [];
  List<String> gramPanchayats = [];

  final String districtsUrl = "https://sbmgrajasthan.com/api/getDistricts";
  final String blocksUrl = "https://sbmgrajasthan.com/api/getBlocks/";
  final String gpUrl = "https://sbmgrajasthan.com/api/getGp/";

  Future<void> loadDistrictFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDistrict = prefs.getString('District');
      selectedBlock = prefs.getString('appbarselectedBlock');
      selectedGramPanchayat = prefs.getString('appbarselectedGramPanchayat');
    });
    if (selectedDistrict != null) {
      fetchBlocks(selectedDistrict!);
    }
    if (selectedBlock != null && selectedDistrict != null) {
      fetchGramPanchayats(selectedDistrict!, selectedBlock!);
    }
  }

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
        String formattedBlock = selectedBlock?.replaceAll(' ', '_') ?? "";
        formattedBlock = formattedBlock.replaceAllMapped(RegExp(r'_(.)'), (match) {
      return '_${match.group(1)?.toLowerCase()}';
    });
    
    print(selectedBlock);
    print(formattedBlock);
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

      String formattedDistrict = selectedDistrict!.replaceAll(' ', '_');
      String formattedBlock = selectedBlock?.replaceAll(' ', '_') ?? "";
      String formattedGramPanchayat =selectedGramPanchayat?.replaceAll(' ', '_') ?? "";

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
      await prefs.setString(
          'appbarselectedGramPanchayat', formattedGramPanchayat);
      Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    loadDistrictFromPrefs();
    _loadLanguagePreference();
  }

  void showOptions(BuildContext context, List<String> options,
      ValueChanged<String> onSelected) {
    List<String> filteredOptions = List.from(options);
    bool isLoading = options.isEmpty;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                            .where((option) => option
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                isLoading
                    ? Center(
                        child: Image.asset(
                          'assets/images/Loder.gif',
                          width: 200,
                          height: 200,
                        ),
                      )
                    : Expanded(
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
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
                        setState(() {
                          selectedGramPanchayat = null;
                          selectedBlock = null;
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
                if (selectedDistrict == null) {
                  showOptions(context, districts, (value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedBlock = null;
                      selectedGramPanchayat = null;
                    });
                    fetchBlocks(value);
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
                      selectedGramPanchayat = null;
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
                  foregroundColor: Colors.grey[800],
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
                    color: Colors.white,
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
