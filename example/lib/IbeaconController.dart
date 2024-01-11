import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:get/get.dart';

class IbeaconController extends GetxController {
  final flutterIbeacon = FlutterIbeacon();
  final isBeaconReady = ["", ""].obs;
  final isAdvertising = false.obs;

  IbeaconController() {
    isBeaconReady.bindStream(flutterIbeacon.isBeaconReady());
    isAdvertising.bindStream(flutterIbeacon.isAdvertising());
  }
}
