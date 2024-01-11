import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ibeacon_example/IbeaconController.dart';
import 'package:flutter_ibeacon_example/request_page.dart';
import 'package:get/get.dart';

import 'main_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IbeaconController controller = Get.find();
    return Obx(() => controller.isBeaconReady[0] == "true"
        ? MainPage()
        : const RequestPage());
  }
}