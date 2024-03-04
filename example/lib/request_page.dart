import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:flutter_ibeacon_example/ibeacon_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IbeaconController controller = Get.find();
    RxString text = "".obs;

    return Scaffold(
        body: Obx(() => Center(
              child: () {
                if (Platform.isAndroid) {
                  switch (controller.isBeaconReady[1]) {
                    case "disabled":
                      return const Text(
                          "Bluetooth is disabled, please enable it");
                    case "unauthorized":
                      text.value = "Bluetooth permission is not granted";
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(text.value),
                          ElevatedButton(
                            onPressed: () async {
                              await Permission.bluetoothConnect
                                  .onDeniedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission denied!');
                              }).onGrantedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission granted!');
                              }).onPermanentlyDeniedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission permanently denied!');
                                openAppSettings();
                              }).request();
                              await Permission.bluetoothAdvertise
                                  .onDeniedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission denied!');
                              }).onGrantedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission granted!');
                              }).onPermanentlyDeniedCallback(() {
                                Fluttertoast.showToast(
                                    msg: 'Permission permanently denied!');
                                openAppSettings();
                              }).request();
                            },
                            child: const Text("Request Permissions"),
                          )
                        ],
                      );
                    case "unsupported":
                      text.value = "Bluetooth LE is not supported";
                      return Text(text.value);
                    default:
                      text.value = "Unknown error";
                      return Text(text.value);
                  }
                  // return Text(text);
                } else if (Platform.isIOS) {
                  switch (controller.isBeaconReady[1]) {
                    case "disabled":
                      text.value = "Bluetooth is disabled, please enable it";
                    case "unauthorized":
                      text.value =
                          "Bluetooth permission is not granted, please enable it in settings";
                    case "unsupported":
                      text.value = "Bluetooth LE is not supported";
                    default:
                      text.value = "Unknown error";
                  }
                  return Text(text.value);
                } else {
                  return const Text("Unsupported Platform");
                }
              }(),
            )));
  }
}
