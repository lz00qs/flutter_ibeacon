import Flutter
import UIKit

public enum ChannelName {
    static let advertisingStatus = "flutter.hylcreative.top/status"
    static let beaconReady = "flutter.hylcreative.top/ready"
    static let method = "flutter.hylcreative.top/method"
    static let log = "flutter.hylcreative.top/log"
}

public class FlutterIbeaconPlugin: NSObject, FlutterPlugin {
    private let flutterIbeaconApi: FlutterIbeaconApi
    
    init(messenger: FlutterBinaryMessenger) {
        // 从 init 里面拿到 flutterBinaryMessenger 数据
        self.flutterIbeaconApi = FlutterIbeaconApi(messenger: messenger)
        super.init()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "Flutter_Ibeacon", binaryMessenger: registrar.messenger())
        
        let instance = FlutterIbeaconPlugin(messenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
