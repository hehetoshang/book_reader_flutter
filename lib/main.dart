import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化PDF引擎，消除WASM警告
  pdfrxFlutterInitialize(dismissPdfiumWasmWarnings: true);
  runApp(const UniversalReaderApp());
}
