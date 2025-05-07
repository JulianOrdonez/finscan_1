import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ScanService {
  static const MethodChannel _channel = MethodChannel('scan_service');

  Future<String?> scanBarcode() async {
    try {
      final String? barcode = await _channel.invokeMethod('scanBarcode');
      return barcode;
    } on PlatformException catch (e) {
      debugPrint('Error al escanear el código de barras: ${e.message}');
      return null;
    }
  }
}