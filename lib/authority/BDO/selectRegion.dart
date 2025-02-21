// authority/BDO/selectRegion.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegionSelector extends StatefulWidget {
  const RegionSelector({Key? key}) : super(key: key);

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedGramPanchayat;

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
    });
  }

  Future<void> loadBDOFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bdo = prefs.getString('Bdo');
    if (bdo != null) {
      selectedBlock = bdo.replaceAll('_', ' ');
      print("BDO: $bdo");
    }
  }

  Future<void> loadGramPanchayatFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGramPanchayat = prefs.getString('appbarselectedGramPanchayat');
    });
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
      await prefs.setString('appbarselectedGramPanchayat', formattedGramPanchayat);
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

  @override
  void initState() {
    super.initState();
    fetchDistricts();
    loadDistrictFromPrefs();
    loadBDOFromPrefs();
    loadGramPanchayatFromPrefs(); // Load Gram Panchayat from SharedPreferences
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
                        child: CircularProgressIndicator(),
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onTap: () async {
                if (selectedBlock != null) {
                  // Show a loading indicator while fetching data
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );

                  // Fetch Gram Panchayats
                  await fetchGramPanchayats(selectedDistrict!, selectedBlock!);

                  // Close the loading indicator
                  Navigator.pop(context);

                  // Show the bottom sheet only if data is available
                  if (gramPanchayats.isNotEmpty) {
                    showOptions(context, gramPanchayats, (value) {
                      setState(() {
                        selectedGramPanchayat = value;
                      });
                    });
                  } else {
                    // Show an error message if no data is available
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('No Data Available'),
                          content: Text(
                              'No Gram Panchayats found for the selected Block.'),
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