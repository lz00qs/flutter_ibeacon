import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:flutter_ibeacon/flutter_ibeacon_platform_interface.dart';
import 'package:flutter_ibeacon/flutter_ibeacon_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterIbeaconPlatform
    with MockPlatformInterfaceMixin
    implements FlutterIbeaconPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterIbeaconPlatform initialPlatform = FlutterIbeaconPlatform.instance;

  test('$MethodChannelFlutterIbeacon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterIbeacon>());
  });

  test('getPlatformVersion', () async {
    FlutterIbeacon flutterIbeaconPlugin = FlutterIbeacon();
    MockFlutterIbeaconPlatform fakePlatform = MockFlutterIbeaconPlatform();
    FlutterIbeaconPlatform.instance = fakePlatform;

    expect(await flutterIbeaconPlugin.getPlatformVersion(), '42');
  });
}
