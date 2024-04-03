import 'package:flutter/services.dart';
import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  FlutterIbeacon platform = FlutterIbeacon();
  const beaconReadyChannel = MethodChannel('flutter.hylcreative.top/ready');
  const beaconStatusChannel = MethodChannel('flutter.hylcreative.top/status');
  const logChannel = MethodChannel('flutter.hylcreative.top/log');
  const methodChannel = MethodChannel('flutter.hylcreative.top/method');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      beaconReadyChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    beaconReadyChannel.name,
                    beaconReadyChannel.codec
                        .encodeSuccessEnvelope(['false', 'unsupported']),
                    null);
          case 'cancel':
          default:
            return null;
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      beaconStatusChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    beaconStatusChannel.name,
                    beaconStatusChannel.codec.encodeSuccessEnvelope(false),
                    null);
          case 'cancel':
          default:
            return null;
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      logChannel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'listen':
            await TestDefaultBinaryMessengerBinding
                .instance.defaultBinaryMessenger
                .handlePlatformMessage(
                    logChannel.name,
                    logChannel.codec.encodeSuccessEnvelope(['info', 'test']),
                    null);
          case 'cancel':
          default:
            return null;
        }
        return null;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'start':
          expect(methodCall.arguments, {
            'uuid': '12345678-1234-1234-1234-123456789012',
            'major': 1,
            'minor': 1,
            'identifier': 'test',
            'txPower': null
          });
          break;
        case 'stop':
          expect(methodCall.method, 'stop');
        default:
          return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(beaconReadyChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(beaconStatusChannel, null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(logChannel, null);
  });

  test('beaconReadyChannel', () async {
    final result = await platform.isBeaconReady().first;
    expect(result[0], 'false');
    expect(result[1], 'unsupported');
  });

  test('beaconStatusChannel', () async {
    final result = await platform.isAdvertising().first;
    expect(result, false);
  });

  test('logChannel', () async {
    final result = await platform.logChannel.receiveBroadcastStream().first;
    expect(result[0], 'info');
    expect(result[1], 'test');
  });

  test('startAdvertising', () async {
    await platform.startAdvertising(
        uuid: '12345678-1234-1234-1234-123456789012',
        major: 1,
        minor: 1,
        identifier: 'test');
  });

  test('stopAdvertising', () async {
    await platform.stopAdvertising();
  });
}
