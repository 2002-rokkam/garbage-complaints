// authority/QRTab.dart
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dio/dio.dart';

class QRTab extends StatelessWidget {
  const QRTab({Key? key}) : super(key: key);

  Future<void> scanQRCode(BuildContext context) async {
    String scannedData;
    try {
      String qrResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      scannedData = qrResult != "-1" ? qrResult : "Scan canceled";
    } catch (e) {
      scannedData = "Failed to scan QR code: $e";
    }

    if (scannedData != "Scan canceled" && !scannedData.startsWith("Failed")) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Scanned Data"),
          content: Text(scannedData),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await submitData(scannedData, context);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(scannedData),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> submitData(String scannedData, BuildContext context) async {
    final dio = Dio();
    const url =
        'https://d029-122-172-86-111.ngrok-free.app/api/submit-activity';

    try {
      FormData formData = FormData.fromMap({
        'section': 'D2D_QR',
        'worker_id': 4,
        'QRAddress': scannedData,
      });

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: Text("Data submitted successfully: ${response.data}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to submit data: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => scanQRCode(context),
        child: Container(
          width: 205.03,
          height: 159.17, // Total height of both containers combined
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, 1.00),
              end: Alignment(0, -1),
              colors: [ Color(0xFFFFC400),Color(0x00FFC400),Color(0x00FFC400)],
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
