// PoweredByBikaji.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';

class PoweredByBikaji extends StatefulWidget {
  const PoweredByBikaji({super.key});

  @override
  _PoweredByBikajiState createState() => _PoweredByBikajiState();
}

class _PoweredByBikajiState extends State<PoweredByBikaji> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 402,
      height: 127,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 11),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 102,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 111,
                  height: 63,
                  child: Image.asset(
                    'assets/images/bikaji.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  width: double.infinity,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Powered By',
                        style: TextStyle(
                          color: Color(0xFF3B4A5C),
                          fontSize: 14,
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Bikaji Foods International Ltd',
                        style: TextStyle(
                          color: Color(0xFF3B4A5C),
                          fontSize: 16,
                          fontFamily: 'Nunito Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
