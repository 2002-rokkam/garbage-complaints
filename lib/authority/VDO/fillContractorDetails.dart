// authority/VDO/fillContractorDetails.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FillContractorDetailsScreen extends StatefulWidget {
  @override
  _ContractorDetailsScreenState createState() =>
      _ContractorDetailsScreenState();
}

class _ContractorDetailsScreenState extends State<FillContractorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();

  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _isEditable = false;

  Future<String> _getWorkerIdFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? workerId = prefs.getString('worker_id');
    return workerId ?? '';
  }

  Future<void> _loadContractorDetails() async {
    final String workerId = await _getWorkerIdFromPrefs(); // Sample worker ID

    try {
      final url = Uri.parse(
          'https://sbmgrajasthan.com/api/contractor/detail/$workerId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Populate the fields with existing contractor details
        final data = jsonDecode(response.body);
        setState(() {
          _isEditing = true;
          _companyNameController.text = data['company_name'];
          _gstNoController.text = data['gst_no'];
          _emailController.text = data['email'];
          _contactNoController.text = data['contact_no'];

          _initialValues = {
            'company_name': data['company_name'],
            'gst_no': data['gst_no'],
            'email': data['email'],
            'contact_no': data['contact_no'],
          };
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _isEditing = false;
          _isEditable =
              true; // Allow the user to enter values manually when no data is found
          // Clear the fields to allow input
          _companyNameController.clear();
          _gstNoController.clear();
          _emailController.clear();
          _contactNoController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToLoadData)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingData)),
      );
      setState(() {
        // If there is an error, allow the user to fill the form manually
        _isEditing = false;
        _isEditable =
            true; // Allow the user to enter data manually in case of error
        _companyNameController.clear();
        _gstNoController.clear();
        _emailController.clear();
        _contactNoController.clear();
      });
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      final String workerId = await _getWorkerIdFromPrefs(); // Sample worker ID

      final url =
          Uri.parse(_isEditing // Decide between update and create endpoints
              ? 'https://sbmgrajasthan.com/api/contractor/update/$workerId'
              : 'https://sbmgrajasthan.com/api/contractor/create/$workerId');
      final payload = {
        'company_name': _companyNameController.text,
        'gst_no': _gstNoController.text,
        'email': _emailController.text,
        'contact_no': _contactNoController.text,
      };

      try {
        final response = await (_isEditing
            ? http.put(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(payload),
              )
            : http.post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(payload),
              ));

        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 200) {
          // Show success dialog
          _showSuccessDialog();
          setState(() {
            _companyNameController.text = _companyNameController.text;
            _gstNoController.text = _gstNoController.text;
            _emailController.text = _emailController.text;
            _contactNoController.text = _contactNoController.text;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.errorSavingData)),
          );
        }
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.errorSavingData)),
        );
        // Show failure dialog
        _showFailureDialog();
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60.0,
                ),
              ),
              const SizedBox(height: 20.0),
              // Title
              Text(
                AppLocalizations.of(context)!.success,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10.0),
              // Content
              Text(
                AppLocalizations.of(context)!.contractorSubmitted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              // OK Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditable = false;
                  });
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Failure Icon
              CircleAvatar(
                radius: 40.0,
                backgroundColor: Colors.red.shade100,
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60.0,
                ),
              ),
              const SizedBox(height: 20.0),
              // Title
              Text(
                AppLocalizations.of(context)!.oops,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10.0),
              // Content
              Text(
                AppLocalizations.of(context)!.contractorFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20.0),
              // Retry Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.tryAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _initialValues = {};

  bool get _hasChanges {
    return _companyNameController.text != _initialValues['company_name'] ||
        _gstNoController.text != _initialValues['gst_no'] ||
        _emailController.text != _initialValues['email'] ||
        _contactNoController.text != _initialValues['contact_no'];
  }

  @override
  void initState() {
    super.initState();
    _loadContractorDetails();

    _companyNameController.addListener(() => setState(() {}));
    _gstNoController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _contactNoController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contractorDetails,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF5C964A),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(
                _isEditable ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isEditable = !_isEditable;
                });
              },
            ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 233, 231, 231),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _companyNameController,
                  label: AppLocalizations.of(context)!.companyName,
                  hint: AppLocalizations.of(context)!.enterCompanyName,
                  icon: Icons.business,
                  enabled: _isEditable,
                  validator: (value) => value!.isEmpty
                      ? AppLocalizations.of(context)!.enterCompanyName
                      : null,
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _gstNoController,
                  label: AppLocalizations.of(context)!.gstNo,
                  hint: 'Enter GST number',
                  icon: Icons.info,
                  enabled: _isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter GST number';
                    }
                    if (value.length != 15) {
                      return 'GST number must be 15 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _emailController,
                  label: AppLocalizations.of(context)!.emailAddress,
                  hint: 'Enter email address',
                  icon: Icons.email,
                  enabled: _isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email address';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter vaid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _contactNoController,
                  label: AppLocalizations.of(context)!.contactNo,
                  hint: 'Enter contact number',
                  icon: Icons.phone,
                  enabled: _isEditable,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    if (value.length != 10) {
                      return 'Contact number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: (_isSubmitting || !_hasChanges || !_isEditable)
                      ? null
                      : _submitDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(_isEditing
                          ? AppLocalizations.of(context)!.update
                          : AppLocalizations.of(context)!.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required bool enabled, // Added this parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled, // Toggle editable state here
          style: TextStyle(
              color: enabled
                  ? const Color.fromARGB(255, 50, 50, 50)
                  : const Color.fromARGB(255, 106, 105, 105)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
