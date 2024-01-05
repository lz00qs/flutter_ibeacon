import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_ibeacon_platform_interface.dart';

/// An implementation of [FlutterIbeaconPlatform] that uses method channels.
class MethodChannelFlutterIbeacon extends FlutterIbeaconPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ibeacon');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
