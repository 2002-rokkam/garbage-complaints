// authority/QRTab.dart

import 'package:flutter/material.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// Add this package


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

    // Show scanned data in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Scanned Data"),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => scanQRCode(context),
            child: const Text("Scan QR Code"),
          ),
        ],
      ),
    );
  }
}
