import Flutter
import UIKit

class FlutterIbeaconApi: NSObject{
    private var eventSink: FlutterEventSink?
    private var timer = Timer()
    
    //    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        //        self.messenger = messenger
        super.init()
        initChannels(messenger: messenger)
    }
}

private extension FlutterIbeaconApi {
    private func initChannels(messenger: FlutterBinaryMessenger) {
        FlutterEventChannel(name: ChannelName.event, binaryMessenger: messenger)
            .setStreamHandler(self)
        FlutterMethodChannel(name: ChannelName.method, binaryMessenger: messenger)
            .setMethodCallHandler(methodCallHandler)
    }
    
}

extension FlutterIbeaconApi: FlutterStreamHandler {
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("onListen....")
        self.eventSink = events
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "HH:mm:ss"
            let time = dateFormat.string(from: Date())
            if self.eventSink != nil {
                self.eventSink!(time)
            }
        })
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

private extension FlutterIbeaconApi {
    private func methodCallHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Swift FlutterIbeaconPlugin: received flutter call: \(call.method)")
        switch call.method {
        case "test":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
