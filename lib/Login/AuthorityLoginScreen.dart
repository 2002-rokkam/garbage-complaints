// Login/AuthorityLoginScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../WokersScreen/WorkerScreen.dart';
import '../authority/BDO/BDOScreen.dart';
import '../authority/CEO/CEOScreen.dart';
import '../authority/SMD/SMDScreen.dart';
import '../authority/VDO/VDOScreen.dart';
import 'PhoneAuthScreen.dart';

class AuthorityLoginScreen extends StatefulWidget {
  @override
  _AuthorityLoginScreenState createState() => _AuthorityLoginScreenState();
}

class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://8da6-122-172-85-234.ngrok-free.app/api/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if login is successful
        if (data['message'] == "Login Successful") {
          final user = data;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('worker_id', user['User Id']);
          await prefs.setString('position', user['Position']);
          await prefs.setString('gram_panchayat', user['gp']);
          await prefs.setString('District', user['District']);
          await prefs.setString('Bdo', user['gp']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful!')),
          );

          if (user['Position'] == 'Worker') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerScreen(),
              ),
            );
          } else if (user['Position'] == 'Vdo') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VDOScreen(), // Navigate to BDO screen
              ),
            );
          } else if (user['Position'] == 'Bdo') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BDOScreen(), // Navigate to BDO screen
              ),
            );
          } else if (user['Position'] == 'Ceo') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CEOScreen(), // Navigate to BDO screen
              ),
            );
          } else if (user['Position'] == 'Aceo') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CEOScreen(), // Navigate to BDO screen
              ),
            );
          } else if (user['Position'] == 'Smd') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SMDScreen(), // Navigate to BDO screen
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unknown position: ${user['Position']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please try again')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials Please try again')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Enter ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Email address',
                          style: TextStyle(
                            color: Color(0xFF5C964A),
                            fontSize: 20,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This information is not shared with anyone',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInputField('Email', _emailController, false),
                  SizedBox(height: 20),
                  _buildInputField('Password', _passwordController, true),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5C964A),
                            minimumSize: Size(370, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PhoneInputScreen(), // Replace with your CitizenLoginScreen
                        ),
                      );
                    },
                    child: Text(
                      'Login as Citizen',
                      style: TextStyle(
                        color: Color(0xFF5C964A),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF252525),
            fontSize: 16,
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}
