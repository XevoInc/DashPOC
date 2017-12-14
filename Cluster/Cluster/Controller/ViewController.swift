//
//  ViewController.swift
//  Cluster
//
//  Created by Mario Bragg on 11/30/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate, WebSocketDelegate {

    @IBOutlet weak var tempGauge: UIImageView!
    @IBOutlet weak var fuelGauge: UIImageView!
    @IBOutlet weak var speedometer: UIImageView!
    @IBOutlet weak var speedometerMask: UIImageView!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var headlightsOn: UIImageView!
    @IBOutlet weak var passengerDoorUnlock: UIImageView!
    @IBOutlet weak var driverDoorUnlock: UIImageView!
    @IBOutlet weak var tireIndicatorOn: UIImageView!
    @IBOutlet weak var brakeIndicatorOn: UIImageView!
    @IBOutlet weak var engineIndicatorOn: UIImageView!
    @IBOutlet weak var oilIndicatorOn: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pmLabel: UILabel!
    @IBOutlet weak var parkGearOn: UIImageView!
    @IBOutlet weak var reverseGearOn: UIImageView!
    @IBOutlet weak var neutralGearOn: UIImageView!
    @IBOutlet weak var driveGearOn: UIImageView!
    @IBOutlet weak var lowGearOn: UIImageView!
    @IBOutlet weak var headlightsIndicatorOn: UIImageView!
    @IBOutlet weak var highBeamIndicatorOn: UIImageView!
    @IBOutlet weak var lockIndicatorOn: UIImageView!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var miLabel: UILabel!
    
    private var clockTimer: Timer?
    private var fuelLevel: Int = 0
    private var engineIsOn = false
    private var tempLevel: Int = 0
    private var speed: Int = 0
    
    private var webSocket: WebSocket?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webSocket = WebSocket(delegate: self)
        setBoldLabels()
        updateTime()
        startClock()
        turnOff(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setBoldLabels() {
        
        mileageLabel.font = UIFont(name: "EurostileBold", size: 36.0)
        timeLabel.font = UIFont(name: "EurostileBold", size: 36.0)
    }
    
    private func startClock() {
        clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(clockTimerUpdated), userInfo: nil, repeats: true)
    }
    
    @objc private func clockTimerUpdated() {
        updateTime()
    }
    
    private func updateTime() {
        
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        var displayHour = hour < 13 ? hour : hour - 12
        if displayHour == 0 {
            displayHour = 12
        }
        
        let minutes = calendar.component(.minute, from: date)
        var minutesString = String(minutes)
        if (minutes < 10)
        {
            minutesString = "0" + minutesString
        }
        
        self.timeLabel.text = "\(displayHour):" + minutesString
        self.pmLabel.text = hour < 13 ? "AM" : "PM"
    }
    
    private func fuelStartup() {
        
        if (fuelLevel < 20)
        {
            fuelLevel += 1
            
            var imageName = "fuel_gauge_fill_\(fuelLevel)"
            if (fuelLevel < 4) {
                imageName = imageName + "_startup"
            }
            
            let image = UIImage(named: imageName)
            self.fuelGauge.image = image
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.fuelStartup()
            })
        }
    }
    
    private func tempStartup() {
        
        if (tempLevel < 10)
        {
            tempLevel += 1
            
            let imageName = "temp_gauge_fill_\(tempLevel)"
            let image = UIImage(named: imageName)
            self.tempGauge.image = image
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.tempStartup()
            })
        }
    }
    
    private var speedometerInit = false
    private func speedometerStartup() {
        
        speedometerMask.image = UIImage(named: "mask_under_60")
        
        let startAngle =  angleForSpeed(speed: speed)
        speed = speedMaximum
        let stopAngle =  angleForSpeed(speed: speed)
        
        speedometerInit = true
        speedometer.rotateWithAnimation(startAngle: startAngle°, stopAngle: stopAngle°, duration: 1.0, delegate: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.speedometerMask.image = UIImage(named: "mask_over_60")
        }
    }
    
    // Mark: - Test
    func testSpeed() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.setSpeed(90)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            self.setSpeed(30)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
            self.setSpeed(105)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 14.0) {
            self.setSpeed(0)
        }
    }
    
    // MARK: - WebsocketDelegate
    
    func startCar(_ start: Bool, animated: Bool)
    {
        if (start) {
            turnOn(animated: animated)
        }
        else {
            turnOff(animated: animated)
        }
    }
    
    private func turnOn(animated: Bool) {
        
        self.engineIsOn = true
        let interval: TimeInterval = animated ? 0.5 : 0.0
        UIView.animate(withDuration: interval, animations: {
            
            self.tempGauge.alpha = 1.0
            self.fuelGauge.alpha = 1.0
            self.speedometer.alpha = 1.0
            self.mphLabel.alpha = 1.0
            self.speedLabel.alpha = 1.0
            self.headlightsOn.alpha = 1.0
            self.passengerDoorUnlock.alpha = 1.0
            self.driverDoorUnlock.alpha = 1.0
            self.tireIndicatorOn.alpha = 1.0
            self.brakeIndicatorOn.alpha = 1.0
            self.engineIndicatorOn.alpha = 1.0
            self.oilIndicatorOn.alpha = 1.0
            self.timeLabel.alpha = 1.0
            self.pmLabel.alpha = 1.0
            self.parkGearOn.alpha = 1.0
            self.reverseGearOn.alpha = 1.0
            self.neutralGearOn.alpha = 1.0
            self.driveGearOn.alpha = 1.0
            self.lowGearOn.alpha = 1.0
            self.headlightsIndicatorOn.alpha = 1.0
            self.highBeamIndicatorOn.alpha = 1.0
            self.lockIndicatorOn.alpha = 1.0
            self.mileageLabel.alpha = 1.0
            self.miLabel.alpha = 1.0
            
        }) { (complete) in
            
            DispatchQueue.main.async {
                self.fuelStartup()
                self.tempStartup()
                self.speedometerStartup()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    //self.tempGauge.alpha = 0.0
                    //self.fuelGauge.alpha = 0.0
                    //self.speedometer.alpha = 0.0
                    //self.mphLabel.alpha = 0.0
                    //self.speedLabel.alpha = 0.0
                    self.headlightsOn.alpha = 0.0
                    self.passengerDoorUnlock.alpha = 0.0
                    self.driverDoorUnlock.alpha = 0.0
                    self.tireIndicatorOn.alpha = 0.0
                    self.brakeIndicatorOn.alpha = 0.0
                    self.engineIndicatorOn.alpha = 0.0
                    self.oilIndicatorOn.alpha = 0.0
                    //self.timeLabel.alpha = 0.0
                    //self.pmLabel.alpha = 0.0
                    //self.parkGearOn.alpha = 0.0
                    self.reverseGearOn.alpha = 0.0
                    self.neutralGearOn.alpha = 0.0
                    self.driveGearOn.alpha = 0.0
                    self.lowGearOn.alpha = 0.0
                    self.headlightsIndicatorOn.alpha = 0.0
                    self.highBeamIndicatorOn.alpha = 0.0
                    self.lockIndicatorOn.alpha = 0.0
                    //self.mileageLabel.alpha = 0.0
                    //self.miLabel.alpha = 0.0
                    
                }) { (complete) in
                }
            })
        }
    }
    
    private func turnOff(animated: Bool) {
        
        self.engineIsOn = false
        let interval: TimeInterval = animated ? 0.5 : 0.0
        UIView.animate(withDuration: interval, animations: {
            
            self.tempGauge.alpha = 0.0
            self.fuelGauge.alpha = 0.0
            self.speedometer.alpha = 0.0
            self.mphLabel.alpha = 0.0
            self.speedLabel.alpha = 0.0
            self.headlightsOn.alpha = 0.0
            self.passengerDoorUnlock.alpha = 0.0
            self.driverDoorUnlock.alpha = 0.0
            self.tireIndicatorOn.alpha = 0.0
            self.brakeIndicatorOn.alpha = 0.0
            self.engineIndicatorOn.alpha = 0.0
            self.oilIndicatorOn.alpha = 0.0
            self.timeLabel.alpha = 0.0
            self.pmLabel.alpha = 0.0
            self.parkGearOn.alpha = 0.0
            self.reverseGearOn.alpha = 0.0
            self.neutralGearOn.alpha = 0.0
            self.driveGearOn.alpha = 0.0
            self.lowGearOn.alpha = 0.0
            self.headlightsIndicatorOn.alpha = 0.0
            self.highBeamIndicatorOn.alpha = 0.0
            self.lockIndicatorOn.alpha = 0.0
            self.mileageLabel.alpha = 0.0
            self.miLabel.alpha = 0.0
            
        }) { (complete) in
            
            self.setSpeed(self.speedMinimum)
            self.speedLabel.text = "0"
            
            self.fuelLevel = 0
            let fuelImage = UIImage(named: "fuel_gauge_fill_1_startup")
            self.fuelGauge.image = fuelImage
            
            self.tempLevel = 0
            let tempImage = UIImage(named: "temp_gauge_fill_1")
            self.tempGauge.image = tempImage
        }
    }
    
    func flashLights() {
        
        setVehicleLights(on: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setVehicleLights(on: false)
        }
    }
    
    // MARK: - Lights
    
    func setVehicleLights(on: Bool) {
        headlightsOn.alpha = on ? 1.0 : 0.0
        headlightsIndicatorOn.alpha = on ? 1.0 : 0.0
    }
    
    func setHighBeam(on: Bool) {
        
        if (on)
        {
            //headlightsOn.alpha = on ? 1.0 : 0.0
            highBeamIndicatorOn.alpha = on ? 1.0 : 0.0
            //headlightsIndicatorOn.alpha = on ? 1.0 : 0.0
        }
        else
        {
            highBeamIndicatorOn.alpha = on ? 1.0 : 0.0
        }
    }
    
    // MARK: - Doors
    
    func setDriversDoor(locked: Bool) {
        driverDoorUnlock.alpha = locked ? 0.0 : 1.0
        lockIndicatorOn.alpha = locked ? 0.0 : 1.0
    }
    
    func setPassengerDoors(locked: Bool) {
        passengerDoorUnlock.alpha = locked ? 0.0 : 1.0
        lockIndicatorOn.alpha = locked ? 0.0 : 1.0
    }
    
    // MARK: - Fuel
    
    func setFuel(_ level: Int) {
        
        var lvl = level
        
        if (lvl < 0) {
            lvl = 0
        }
        else if (lvl > 100) {
            lvl = 100
        }
        
        let setLvl = Int(roundf(Float(lvl) / Float(5)))
        
        if (setLvl > 0 && setLvl < 21)
        {
            let image = UIImage(named: "fuel_gauge_fill_\(setLvl)")
            self.fuelGauge.image = image
        }
    }
    
    // MARK: - Temp
    
    func setTemp(_ level: Int) {
        
        var lvl = level
        
        if (lvl < 0) {
            lvl = 0
        }
        else if (lvl > 100) {
            lvl = 100
        }
        
        let setLvl = Int(roundf(Float(lvl) / Float(5)))
        
        if (setLvl > 0 && setLvl < 21)
        {
            let image = UIImage(named: "temp_gauge_fill_\(setLvl)")
            self.tempGauge.image = image
        }
    }
    
    // MARK: - Odemeter
    
    func setOdometer(mileage: Float) {
        
        let mileageString = String(format: "%0.1f", mileage)
        mileageLabel.text = mileageString
    }
    
    // MARK: - Indicators
    
    func setTireIndicator(on: Bool) {
        tireIndicatorOn.alpha = on ? 1.0 : 0.0
    }
    
    func setBrakeIndicator(on: Bool) {
        brakeIndicatorOn.alpha = on ? 1.0 : 0.0
    }
    
    func setEngineIndicator(on: Bool) {
        engineIndicatorOn.alpha = on ? 1.0 : 0.0
    }
    
    func setOilIndicator(on: Bool) {
        oilIndicatorOn.alpha = on ? 1.0 : 0.0
    }
    
    // MARK: - Set Gear
    
    func setGear(gear: Gear) {
        
        parkGearOn.alpha = 0.0
        reverseGearOn.alpha = 0.0
        neutralGearOn.alpha = 0.0
        driveGearOn.alpha = 0.0
        lowGearOn.alpha = 0.0
        
        switch gear {
            case .park:
                parkGearOn.alpha = 1.0
            case .reverse:
                reverseGearOn.alpha = 1.0
            case .neutral:
                neutralGearOn.alpha = 1.0
            case .drive:
                driveGearOn.alpha = 1.0
            case .low:
                lowGearOn.alpha = 1.0
        }
    }
    
    // MARK: - Set Speed

    private var maskSwitchoverSpeed: Int = 60
    private var speedMinimum: Int = 0
    private var speedMaximum: Int  = 120
    private var speedTimer = Timer()
    
    func setSpeed(_ newSpeed: Int) {
        
        if (self.speed == newSpeed) {return}
        
        var validSpeed = newSpeed
        
        if (validSpeed < speedMinimum) {
            validSpeed = speedMinimum
        }
        else if (validSpeed > speedMaximum) {
            validSpeed = speedMaximum
        }
        
        let startAngle = angleForSpeed(speed: self.speed)
        let stopAngle = angleForSpeed(speed: validSpeed)
        
        var switchoverPct: Float = 0.0
        var range: Float?
        if (self.speed < maskSwitchoverSpeed && validSpeed > maskSwitchoverSpeed ||
            self.speed > maskSwitchoverSpeed && validSpeed < maskSwitchoverSpeed)
        {
            if (self.speed < maskSwitchoverSpeed)
            {
                range = Float(maskSwitchoverSpeed - self.speed)
                switchoverPct = Float(range! / Float(validSpeed - self.speed))
            }
            else
            {
                range = Float(self.speed - maskSwitchoverSpeed)
                switchoverPct = Float(range! / Float(self.speed - validSpeed))
            }
        }
        
        speedometer.rotateWithAnimation(startAngle: startAngle°, stopAngle: stopAngle°, duration: 1.0, delegate: self)
        _ = INTUAnimationEngine.animate(withDuration: 1.0, delay: 0.0, animations: { (progress) in
            
            if (validSpeed > 0)
            {
                self.setGear(gear: .drive)
            }

            self.updateSpeedLabel(progress: Float(progress), startSpeed: self.speed, endSpeed: validSpeed, maskSwitch: switchoverPct)
            
        }, completion: { (complete) in
            
            self.speed = validSpeed
            self.speedLabel.text = String(describing: Int(validSpeed))
            self.maskSet = false
            
            if (validSpeed == 0)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.setGear(gear: .park)
                })
            }
        })
    }
    
    private var maskSet = false
    private func updateSpeedLabel(progress: Float, startSpeed: Int, endSpeed: Int, maskSwitch: Float) {
        
        let increment = startSpeed < endSpeed
        let range = abs(startSpeed - endSpeed)
        var speedInc: Int?
        
        if (increment) {
            speedInc = Int(roundf(progress * Float(range)))
        } else {
            speedInc = -Int(roundf(progress * Float(range)))
        }
                
        let speed2 = startSpeed + speedInc!
        self.speedLabel.text = String(describing: speed2)
        
        if (maskSwitch > 0.0 && !maskSet)
        {
                if (speed2 > self.maskSwitchoverSpeed - 10 && speed2 < self.maskSwitchoverSpeed && increment) {
                    self.speedometerMask.image = UIImage(named: "mask_over_60")
                    self.maskSet = true
                }
                else if (speed2 < self.maskSwitchoverSpeed && speed2 > self.maskSwitchoverSpeed - 10 && !increment) {
                    self.speedometerMask.image = UIImage(named: "mask_under_60")
                    self.maskSet = true
                }
        }
    }

    // MARK: - CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if (speedometerInit)
        {
            let startAngle =  angleForSpeed(speed: speed)
            speed = speedMinimum
            let stopAngle =  angleForSpeed(speed: speed)

            speedometerInit = false
            speedometer.rotateWithAnimation(startAngle: startAngle°, stopAngle: stopAngle°, duration: 1.0, delegate: self)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.speedometerMask.image = UIImage(named: "mask_under_60")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func angleForSpeed(speed: Int) -> CGFloat {
        
        //40 mph = 90 deg
        let deg: CGFloat = 2.25
        let angle =  CGFloat(CGFloat(speed) * deg)
        return angle
    }

    // MARK: - Fonts
    
    //        Eurostile
    //            == EurostileRegular
    //            == EurostileBold
    
    //        for family: String in UIFont.familyNames
    //        {
    //            print("\(family)")
    //            for names: String in UIFont.fontNames(forFamilyName: family)
    //            {
    //                print("== \(names)")
    //            }
    //        }
}

postfix operator °

protocol IntegerInitializable: ExpressibleByIntegerLiteral {
    init (_: Int)
}

extension Int: IntegerInitializable {
    postfix public static func °(lhs: Int) -> CGFloat {
        return CGFloat(lhs) * .pi / 180
    }
}

extension CGFloat: IntegerInitializable {
    postfix public static func °(lhs: CGFloat) -> CGFloat {
        return lhs * .pi / 180
    }
}

extension UIImageView {
    
    func rotateWithAnimation(startAngle: CGFloat, stopAngle: CGFloat, duration: CGFloat? = nil, delegate: CAAnimationDelegate? = nil) {
        let pathAnimation = CABasicAnimation(keyPath: "transform.rotation")
        pathAnimation.duration = CFTimeInterval(duration ?? 2.0)
        pathAnimation.fromValue = startAngle
        pathAnimation.toValue = stopAngle
        pathAnimation.delegate = delegate
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        self.transform = transform.rotated(by: stopAngle - startAngle)
        self.layer.add(pathAnimation, forKey: "transform.rotation")
    }
}

