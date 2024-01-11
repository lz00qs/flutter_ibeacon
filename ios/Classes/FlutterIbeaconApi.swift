import Flutter
import UIKit
import CoreLocation
import CoreBluetooth

class FlutterIbeaconApi: NSObject, CBPeripheralManagerDelegate{
    private var peripheralManager: CBPeripheralManager!
    private var eventSink: FlutterEventSink?
    private var timer = Timer()
    private let log = Logger()
    private var beaconReadyHandler: BeaconReadyHandler!
    
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.beaconReadyHandler = BeaconReadyHandler()
        initChannels(messenger: messenger)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if beaconReadyHandler.eventSink != nil {
            var status = ["false",""]
            switch self.peripheralManager.state {
            case .poweredOn:
                status[0] = "true"
            case .poweredOff:
                status[1] = "disabled"
            case .unauthorized:
                status[1] = "unauthorized"
            case .unsupported:
                status[1] = "unsupported"
            default:
                status[1] = "unknowError"
            }
            self.log.d("\(status)")
            beaconReadyHandler.eventSink?(status)
        }
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

private class BeaconReadyHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}



private extension FlutterIbeaconApi {
    private func initChannels(messenger: FlutterBinaryMessenger) {
        FlutterEventChannel(name: ChannelName.advertisingStatus, binaryMessenger: messenger)
            .setStreamHandler(self)
        FlutterEventChannel(name: ChannelName.beaconReady, binaryMessenger: messenger)
            .setStreamHandler(beaconReadyHandler)
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
    private func checkPermission() {
        if let permission = Bundle.main.infoDictionary?["NSBluetoothAlwaysUsageDescription"] as? String {
            log.d("App拥有NSBluetoothAlwaysUsageDescription权限描述: \(permission)")
        } else {
            log.d("App没有NSBluetoothAlwaysUsageDescription权限描述")
        }
    }
    
    
    private func methodCallHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Swift FlutterIbeaconPlugin: received flutter call: \(call.method)")
        switch call.method {
        case "test":
            result("iOS " + UIDevice.current.systemVersion)
        case "start":
            let map = call.arguments as? Dictionary<String, Any>
            //            if map != nil {
            //                log.d("\(map!)")
            //            }
            checkPermission()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
