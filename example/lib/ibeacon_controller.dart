import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'objectbox.dart';

class IbeaconController extends GetxController {
  final flutterIbeacon = FlutterIbeacon();
  final isBeaconReady = ["", ""].obs;
  final isAdvertising = false.obs;
  final beaconIndex = 0.obs;

  late ObjectBox objectBox;

  IbeaconController() {
    isBeaconReady.bindStream(flutterIbeacon.isBeaconReady());
    isAdvertising.bindStream(flutterIbeacon.isAdvertising());
  }

  Future<void> updateIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("Index", index.toString());
    beaconIndex.value = index;
  }

  Future<void> getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var index = prefs.getString("Index");
    if (index != null) {
      beaconIndex.value = int.parse(index);
    }
  }
}
