import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  Future<void> startAdvertising({required String uuid, required int major, required int minor, required String identifier,
      int? txPower}) async {
    Map params = <String, dynamic>{
      "uuid": uuid,
      "major": major,
      "minor": minor,
      "identifier": identifier,
      "txPower": txPower
    };
    await _methodChannel.invokeMethod('start', params);
  }

  Future<void> stopAdvertising() async {
    await _methodChannel.invokeMethod('stop');
  }

  Future<void> getReadyStatus() async {
    await _methodChannel.invokeMethod('ready');
  }
}

bool isValidBeaconUUID(String uuid) {
  RegExp uuidRegex = RegExp(
      r'^[\dA-Fa-f]{8}-[\dA-Fa-f]{4}-[\dA-Fa-f]{4}-[\dA-Fa-f]{4}-[\dA-Fa-f]{12}$');
  return uuidRegex.hasMatch(uuid);
}

bool isValidBeaconIdentifier(String input) {
  RegExp domainRegex =
  RegExp(r'^[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*(\.[a-zA-Z]{2,})$');
  return domainRegex.hasMatch(input);
}
