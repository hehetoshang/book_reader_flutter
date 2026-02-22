import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const UniversalReaderAppWrapper());
}
