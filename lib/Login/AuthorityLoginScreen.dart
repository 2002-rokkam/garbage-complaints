// Login/AuthorityLoginScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
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
  const AuthorityLoginScreen({super.key});

  @override
  _AuthorityLoginScreenState createState() => _AuthorityLoginScreenState();
}

class _AuthorityLoginScreenState extends State<AuthorityLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://sbmgrajasthan.com/api/login'),
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
            const SnackBar(content: Text('Login successful!')),
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
            const SnackBar(content: Text('Please try again')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials Please try again')),
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
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    localizations.login,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Nunito Sans',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: localizations.emailAddress,
                          style: const TextStyle(
                            color: Color(0xFF5C964A),
                            fontSize: 20,
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localizations.info_not_shared,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                      localizations.email, _emailController, false),
                  const SizedBox(height: 20),
                  _buildInputField(
                      localizations.password, _passwordController, true),
                  const SizedBox(height: 30),
                  _isLoading
                      ? Center(
                          child: Image.asset(
                            'assets/images/Loder.gif',
                            width: 200,
                            height: 200,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C964A),
                            minimumSize: const Size(370, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: Text(
                            localizations.submit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PhoneInputScreen(), // Replace with your CitizenLoginScreen
                        ),
                      );
                    },
                    child: Text(
                      localizations.login_citizen,
                      style: const TextStyle(
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
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF252525),
            fontSize: 16,
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.pleaseEnterPassword;
            }
            return null;
          },
        ),
      ],
    );
  }
}
