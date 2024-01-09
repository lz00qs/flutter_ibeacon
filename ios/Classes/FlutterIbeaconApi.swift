import Flutter
import UIKit
import CoreLocation

class FlutterIbeaconApi: NSObject{
    private var eventSink: FlutterEventSink?
    private var timer = Timer()
    private let log = Logger()
    
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        initChannels(messenger: messenger)
    }
}

private class Logger : NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    private func sendStringArray(_ stringArray: [String]) {
        eventSink?(stringArray)
    }
    
    func d(_ text: String) {
        sendStringArray(["Debug", "iOS: \(text)"])
    }
    
    func i(_ text: String) {
        sendStringArray(["Info", "iOS: \(text)"])
    }
    
    func w(_ text: String) {
        sendStringArray(["Warning", "iOS: \(text)"])
    }
    
    func e(_ text: String) {
        sendStringArray(["Error", "iOS: \(text)"])
    }
}



private extension FlutterIbeaconApi {
    private func initChannels(messenger: FlutterBinaryMessenger) {
        FlutterEventChannel(name: ChannelName.event, binaryMessenger: messenger)
            .setStreamHandler(self)
        FlutterMethodChannel(name: ChannelName.method, binaryMessenger: messenger)
            .setMethodCallHandler(methodCallHandler)
        FlutterEventChannel(name: ChannelName.log, binaryMessenger: messenger).setStreamHandler(log)
    }
    
}

extension FlutterIbeaconApi: FlutterStreamHandler {
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
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
        case "start":
            let map = call.arguments as? Dictionary<String, Any>
            if map != nil {
                log.d("\(map!)")
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
