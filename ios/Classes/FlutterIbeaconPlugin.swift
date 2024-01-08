import Flutter
import UIKit

public enum ChannelName {
    static let event = "flutter.hylcreative.top/event"
    static let method = "flutter.hylcreativ.top/method"
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
        print("Swift FlutterIbeaconPlugin: received flutter call: \(call.method)")
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
