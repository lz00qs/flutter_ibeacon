import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ibeacon_method_channel.dart';

abstract class FlutterIbeaconPlatform extends PlatformInterface {
  /// Constructs a FlutterIbeaconPlatform.
  FlutterIbeaconPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterIbeaconPlatform _instance = MethodChannelFlutterIbeacon();

  /// The default instance of [FlutterIbeaconPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterIbeacon].
  static FlutterIbeaconPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterIbeaconPlatform] when
  /// they register themselves.
  static set instance(FlutterIbeaconPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
