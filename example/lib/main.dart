import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_ibeacon/beacon_data.dart';
import 'package:flutter_ibeacon_example/IbeaconController.dart';
import 'package:flutter_ibeacon_example/main_page.dart';
import 'package:flutter_ibeacon_example/splash_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(IbeaconController());
    return const GetMaterialApp(
      debugShowCheckedModeBanner: true,
      // home: MainPage(),
      home: SplashPage(),
    );
  }
}
