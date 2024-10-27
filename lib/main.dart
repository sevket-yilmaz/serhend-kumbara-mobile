import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serhend_map/helpers/https_helper.dart';
import 'package:serhend_map/map_page.dart';

void main() {
  HttpOverrides.global = MyHttpsOverrides();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: const MapPage()));
}
