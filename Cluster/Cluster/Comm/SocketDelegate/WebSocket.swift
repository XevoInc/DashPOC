//
//  WebSocket.swift
//  Cluster
//
//  Created by Mario Bragg on 12/13/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

protocol WebSocketDelegate: AnyObject {
    func startCar(_ start: Bool, animated: Bool)
    func flashLights()
    func setVehicleLights(on: Bool)
    func setHighBeam(on: Bool)
    func setDriversDoor(locked: Bool)
    func setPassengerDoors(locked: Bool)
    func setSpeed(_ newSpeed: Int)
    func setFuel(_ level: Int)
    func setTemp(_ level: Int)
    func setGear(gear: Gear)
    func setTireIndicator(on: Bool)
    func setBrakeIndicator(on: Bool)
    func setEngineIndicator(on: Bool)
    func setOilIndicator(on: Bool)
    func setOdometer(mileage: Float)
}

enum Gear {
    case park
    case reverse
    case neutral
    case drive
    case low
}

class WebSocket: NSObject, DemoWebSocketDelegate {

    private var webSocket: DemoWebSocket?
    private weak var webSocketDelegate: WebSocketDelegate?
    
    init(delegate: WebSocketDelegate) {
        super.init()
        
        setupWebSocket()
        webSocketDelegate = delegate
    }
    
    private func setupWebSocket() {
                
        webSocket = DemoWebSocket()
        webSocket?.delegate = self
        webSocket?.beginSession()
    }
    
    private func updateSocketDelegate(setting: String, value: String) {
        
        switch setting {
            
            case "vehicleRunning":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.startCar(Bool(value)!, animated: true)
                }
            case "lightsFlashing":
                if (valueIsBool(value: value))
                {
                    if (Bool(value))! {
                        webSocketDelegate?.flashLights()
                    }
                }
            case "vehicleLights":
                if (valueIsOnOff(value: value))
                {
                    webSocketDelegate?.setVehicleLights(on: value.lowercased() == "on" ? true: false)
                }
            case "driverLocked":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setDriversDoor(locked: Bool(value)!)
                }
            case "passengerLocked":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setPassengerDoors(locked: Bool(value)!)
                }
            case "vehicleSpeed":
                if (valueIsInt(value: value))
                {
                    webSocketDelegate?.setSpeed(Int(value)!)
                }
            case "fuelPercent":
                if (valueIsInt(value: value))
                {
                    webSocketDelegate?.setFuel(Int(value)!)
                }
            case "engineTemp":
                if (valueIsInt(value: value))
                {
                    webSocketDelegate?.setTemp(Int(value)!)
                }
            case "vehicleGear":
                if (valueIsGear(value: value))
                {
                    webSocketDelegate?.setGear(gear: gearForValue(value: value))
                }
            case "tireIndicatorOn":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setTireIndicator(on: Bool(value)!)
                }
            case "brakeIndicatorOn":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setBrakeIndicator(on: Bool(value)!)
                }
            case "engineIndicatorOn":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setEngineIndicator(on: Bool(value)!)
                }
            case "oilIndicatorOn":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setOilIndicator(on: Bool(value)!)
                }
            case "brightIndicatorOn":
                if (valueIsBool(value: value))
                {
                    webSocketDelegate?.setHighBeam(on: Bool(value)!)
                }
            case "odometerLevel":
                if (valueIsFloat(value: value))
                {
                    webSocketDelegate?.setOdometer(mileage: Float(value)!)
                }
        default:
            break
        }
    }
    
    private func valueIsBool(value: String) -> Bool {
        let val = Bool(value)
        return val != nil ? true : false
    }
    
    private func valueIsOnOff(value: String) -> Bool {
        let val = value.lowercased()
        return (val == "on" || val == "off")
    }
    
    private func valueIsInt(value: String) -> Bool {
        let val = Int(value)
        return val != nil
    }
    
    private func valueIsFloat(value: String) -> Bool {
        let val = Float(value)
        return val != nil
    }

    private func valueIsGear(value: String) -> Bool {
        let val = value.lowercased()
        return (val == "p" || val == "r" || val == "n" || val == "d" || val == "l")
    }
    
    private func gearForValue(value: String) -> Gear {
        
        switch value.lowercased() {
        case "p":
            return .park
        case "r":
            return .reverse
        case "n":
            return .neutral
        case "d":
            return .drive
        case "l":
            return .low
        default:
            return .park
        }
    }
    
    // MARK: - DemoWebSocketDelegate
    
    func valueChanged(_ setting: String!, value: String!) {
        print("setting: \(setting!) value: \(value!)")
        updateSocketDelegate(setting: setting!, value: value!)
    }
}
