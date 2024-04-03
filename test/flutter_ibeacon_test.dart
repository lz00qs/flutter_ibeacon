import 'dart:async';

import 'package:flutter/src/services/platform_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPluginTestPlatform
    with MockPlatformInterfaceMixin
    implements FlutterIbeacon {
  final _isBeaconReadyController = StreamController<List<String>>.broadcast();
  final _isAdvertisingController = StreamController<bool>.broadcast();

  @override
  Future<void> getReadyStatus() async {
    _isBeaconReadyController.add(['false', 'unsupported']);
  }

  @override
  Stream<bool> isAdvertising() {
    return _isAdvertisingController.stream;
  }

  @override
  Stream<List<String>> isBeaconReady() {
    return _isBeaconReadyController.stream;
  }

  @override
  Future<void> startAdvertising(
      {required String uuid,
      required int major,
      required int minor,
      required String identifier,
      int? txPower}) async {
    _isAdvertisingController.add(true);
  }

  @override
  Future<void> stopAdvertising() async {
    _isAdvertisingController.add(false);
  }

  @override
  // TODO: implement logChannel
  EventChannel get logChannel => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakePlatform = MockFlutterPluginTestPlatform();

  test('getReadyStatus', () async {
    final subscription = fakePlatform.isBeaconReady().listen((event) {
      expect(event[0], 'false');
      expect(event[1], 'unsupported');
    });
    fakePlatform.getReadyStatus();
    subscription.cancel();
  });

  test('startAdvertising', () async {
    final subscription = fakePlatform.isAdvertising().listen((event) {
      expect(event, true);
    });
    fakePlatform.startAdvertising(
        uuid: '12345678-1234-1234-1234-123456789012',
        major: 1,
        minor: 1,
        identifier: 'test');
    subscription.cancel();
  });

  test('stopAdvertising', () async {
    final subscription = fakePlatform.isAdvertising().listen((event) {
      expect(event, false);
    });
    fakePlatform.stopAdvertising();
    subscription.cancel();
  });
}
