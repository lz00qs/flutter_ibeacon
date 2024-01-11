import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'IbeaconController.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IbeaconController controller = Get.find();

    return Scaffold(
        body: Obx(() => Center(
              child: () {
                if (Platform.isAndroid) {
                  return const Text("Android not implement");
                } else if (Platform.isIOS) {
                  var text = "";
                  switch (controller.isBeaconReady[1]) {
                    case "disabled":
                      text = "Bluetooth is disabled, please enable it";
                    case "unauthorized":
                      text =
                          "Bluetooth permission is not granted, please enable it in settings";
                    case "unsupported":
                      text = "Bluetooth LE is not supported";
                    default:
                      text = "Unknow error";
                  }
                  return Text(text);
                } else {
                  return const Text("Unsupport Platform");
                }
              }(),
            )));
  }
}
