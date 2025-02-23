// authority/SMD/SMDselectRegion.dart

import 'dart:convert';
import 'package:flutter/material.dart';
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

  final String districtsUrl =
      "https://334e-122-172-86-132.ngrok-free.app/api/getDistricts";
  final String blocksUrl =
      "https://334e-122-172-86-132.ngrok-free.app/api/getBlocks/";
  final String gpUrl = "https://334e-122-172-86-132.ngrok-free.app/api/getGp/";

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
    if (selectedDistrict != null &&
        selectedBlock != null &&
        selectedGramPanchayat != null) {
      String formattedDistrict = selectedDistrict!.replaceAll(' ', '_');
      String formattedBlock = selectedBlock!.replaceAll(' ', '_');
      String formattedGramPanchayat =
          selectedGramPanchayat!.replaceAll(' ', '_');

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
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Please select all fields before submitting.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> loadSavedSelections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDistrict = prefs.getString('appbarselectedDistrict');
      selectedBlock = prefs.getString('appbarselectedBlock');
      selectedGramPanchayat = prefs.getString('appbarselectedGramPanchayat');
    });

    // Load blocks and gram panchayats based on saved selections
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
    fetchDistricts(); // Fetch districts when the page loads
    loadSavedSelections(); // Load saved selections
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
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
