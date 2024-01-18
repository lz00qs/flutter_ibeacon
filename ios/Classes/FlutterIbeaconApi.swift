import Flutter
import UIKit
import CoreLocation
import CoreBluetooth

class FlutterIbeaconApi: NSObject, CBPeripheralManagerDelegate{
    private var peripheralManager: CBPeripheralManager!
    private var isAdvHandler = IsAdvHandler()
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
            .setStreamHandler(isAdvHandler)
        FlutterEventChannel(name: ChannelName.beaconReady, binaryMessenger: messenger)
            .setStreamHandler(beaconReadyHandler)
        FlutterMethodChannel(name: ChannelName.method, binaryMessenger: messenger)
            .setMethodCallHandler(methodCallHandler)
        FlutterEventChannel(name: ChannelName.log, binaryMessenger: messenger).setStreamHandler(log)
    }
    
}

private class IsAdvHandler: NSObject, FlutterStreamHandler {
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
    
    private func methodCallHandler(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Swift FlutterIbeaconPlugin: received flutter call: \(call.method)")
        switch call.method {
        case "test":
            result("iOS " + UIDevice.current.systemVersion)
        case "start":
            let map = call.arguments as? Dictionary<String, Any>
            if map != nil {
                let region = try? safeCreateCLBeaconRegion(map!)
                let txPower = map?["txPower"] as? NSNumber
                if region != nil {
                    let beaconPeripheralData = region?.peripheralData(withMeasuredPower: txPower)
                    if beaconPeripheralData != nil {
                        peripheralManager.startAdvertising(((beaconPeripheralData! as NSDictionary) as! [String : Any]))
                        log.d("Advertising!!!")
                        self.isAdvHandler.eventSink?(true)
                    }
                }
            }
            
            result(nil)
        case "stop":
            peripheralManager.stopAdvertising()
            self.isAdvHandler.eventSink?(false)
            result(nil)
        case "ready":
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
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func safeCreateCLBeaconRegion(_ map: Dictionary<String, Any>) throws -> CLBeaconRegion? {
        let proximityUUIDString = map["uuid"] as? String
        let majorInt = map["major"] as? Int
        let minorInt = map["minor"] as? Int
        let identifier = map["identifier"] as? String
        
        if (proximityUUIDString != nil) && (majorInt != nil) && (minorInt != nil) && (identifier != nil) {
            let proximityUUID = UUID(uuidString: proximityUUIDString!)
            let major = CLBeaconMajorValue(majorInt!)
            let minor = CLBeaconMinorValue(minorInt!)
            if (proximityUUID != nil) {
                return CLBeaconRegion(uuid: proximityUUID!, major: major, minor: minor, identifier: identifier!)
            }
        }
        return nil
    }
}

private extension FlutterIbeaconApi {
    private func startBeaconing(_ region: CLBeaconRegion) {
        
    }
}
