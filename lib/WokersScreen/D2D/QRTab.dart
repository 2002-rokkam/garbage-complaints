// WokersScreen/D2D/QRTab.dart
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRTab extends StatefulWidget {
  const QRTab({Key? key}) : super(key: key);

  @override
  _QRTabState createState() => _QRTabState();
}

class _QRTabState extends State<QRTab> {
  String scannedData = "";
  late Future<String> _workerIdFuture;

  @override
  void initState() {
    super.initState();
    _workerIdFuture = _getWorkerId();
  }

  Future<String> _getWorkerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('worker_id') ?? '';
  }

  Future<void> scanQRCode() async {
    try {
      String qrResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      setState(() {
        scannedData = qrResult != "-1" ? qrResult : "Scan canceled";
      });
    } catch (e) {
      setState(() {
        scannedData = "Failed to scan QR code: $e";
      });
    }

    if (scannedData != "Scan canceled" && !scannedData.startsWith("Failed")) {
      _showConfirmDialog(scannedData);
    } else {
      _showErrorDialog(scannedData);
    }
  }

  Future<void> submitData(String scannedData, String workerId) async {
    final dio = Dio();
    const url = 'http://167.71.230.247/api/submit-activity';

    try {
      FormData formData = FormData.fromMap({
        'section': 'D2D_QR',
        'worker_id': workerId,
        'QRAddress': scannedData,
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      _showSuccessDialog(response.data.toString());
    } catch (e) {
      _showErrorDialog("Failed to submit data: $e");
    }
  }

  void _showConfirmDialog(String scannedData) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        future: _workerIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              title: Text("Loading"),
              content: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Worker ID not found. Please log in again."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"),
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: const Text("Scanned Data"),
              content: Text(scannedData),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    submitData(scannedData, snapshot.data!);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: scanQRCode,
        child: Container(
          width: 205.03,
          height: 159.17,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, 1.00),
              end: Alignment(0, -1),
              colors: [Color(0xFFFFC400), Color(0x00FFC400), Color(0x00FFC400)],
            ),
          ),
          child: Center(
            child: Image.asset('images/QR.png'),
          ),
        ),
      ),
    );
  }
}
