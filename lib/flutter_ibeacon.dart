import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ibeacon/beacon_data.dart';

class FlutterIbeacon {
  final _advertisingStatusChannel =
      const EventChannel('flutter.hylcreative.top/status');
  final _beaconReadyChannel =
      const EventChannel('flutter.hylcreative.top/ready');
  final _methodChannel = const MethodChannel('flutter.hylcreative.top/method');
  final _logChannel = const EventChannel('flutter.hylcreative.top/log');

  FlutterIbeacon() {
    _logChannel.receiveBroadcastStream().listen((event) {
      try {
        final stringArray = List<String>.from(event);
        final logLevel = stringArray[0];
        final logMessage = stringArray[1];
        if (kDebugMode) {
          debugPrint('[$logLevel] $logMessage');
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  Stream<bool> isAdvertising() {
    return _advertisingStatusChannel.receiveBroadcastStream().cast<bool>();
  }

  Stream<List<String>> isBeaconReady() {
    StreamController<List<String>> controller =
        StreamController<List<String>>();
    _beaconReadyChannel.receiveBroadcastStream().listen((event) {
      try {
        final stringArray = List<String>.from(event);
        controller.add(stringArray);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }, onDone: () {
      controller.close();
    });
    return controller.stream;
  }

  Future<void> startAdvertising(BeaconData beaconData) async {
    Map params = <String, dynamic>{
      "uuid": beaconData.uuid,
      "major": beaconData.major,
      "minor": beaconData.minor,
      "identifier": beaconData.identifier,
      "txPower": beaconData.txPower
    };
    await _methodChannel.invokeMethod('start', params);
  }

  Future<void> stopAdvertising() async {
    await _methodChannel.invokeMethod('stop');
  }
}
