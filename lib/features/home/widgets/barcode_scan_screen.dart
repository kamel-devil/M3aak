import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;

          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          // Filter to only accept barcode formats (exclude QR codes)
          final barcode = barcodes.firstWhere(
            (b) => _isBarcodeFormat(b.format),
            orElse: () => barcodes.first,
          );

          final raw = barcode.rawValue;
          if (raw == null || raw.trim().isEmpty) return;

          _handled = true;
          Navigator.pop(context, raw.trim()); // return barcode string
        },
      ),
    );
  }

  /// Check if the barcode format is a barcode (not QR code)
  bool _isBarcodeFormat(BarcodeFormat format) {
    const barcodeFormats = [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.codabar,
      BarcodeFormat.itf14,
    ];
    return barcodeFormats.contains(format);
  }
}