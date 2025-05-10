# flutter_application_2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

ngrok.exe http 8000


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
 
      final localizations = AppLocalizations.of(context)!;
     
     localizations.qrDetails



      Center(
                child: Image.asset(
                  'assets/images/Loder.gif',
                  width: 200, 
                  height: 200,
                ),
              )


CircularProgressIndicator()

cnvert t  hindi fr app localicatin

cnvert the text whuch is nt cnverted to localisation . use frm hi.arb and en.erb if nt there add it in them



