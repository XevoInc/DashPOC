//
//  ViewController.swift
//  Cluster
//
//  Created by Mario Bragg on 11/30/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet weak var tempGauge: UIImageView!
    @IBOutlet weak var fuelGauge: UIImageView!
    @IBOutlet weak var speedometer: MTCircularSlider!
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
    
    enum Gear {
        case park
        case reverse
        case neutral
        case drive
        case low
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBoldLabels()
        updateTime()
        startClock()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        tap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        
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
    
    // MARK: - Run Modes
    
    func turnOn(animated: Bool) {
        
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
                self.initFuel()
                self.initTemp()
                self.initSpeedometer()
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
                    //self.oilIndicatorOn.alpha = 0.0
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
    
    func turnOff(animated: Bool) {
        
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
            
            self.speedometer.value = 0.0
            self.speedometer.removeTarget(self, action: #selector(self.speedometerChanged(_:)), for: .valueChanged)
            self.speedLabel.text = "0"
            
            self.fuelLevel = 0
            let fuelImage = UIImage(named: "fuel_gauge_fill_1_startup")
            self.fuelGauge.image = fuelImage
            
            self.tempLevel = 0
            let tempImage = UIImage(named: "temp_gauge_fill_1")
            self.tempGauge.image = tempImage
        }
    }
    
    // MARK: - Lights
    
    func lights(areOn: Bool) {
        headlightsOn.alpha = areOn ? 1.0 : 0.0
        headlightsIndicatorOn.alpha = areOn ? 1.0 : 0.0
    }
    
    func flashLights() {
        
        lights(areOn: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.lights(areOn: false)
        }
    }
    
    func highBeam(isOn: Bool) {
        headlightsOn.alpha = isOn ? 1.0 : 0.0
        highBeamIndicatorOn.alpha = isOn ? 1.0 : 0.0
    }
    
    // MARK: - Doors
    
    func driversDoor(isUnlocked: Bool) {
        driverDoorUnlock.alpha = isUnlocked ? 1.0 : 0.0
        lockIndicatorOn.alpha = isUnlocked ? 1.0 : 0.0
    }
    
    func passengerDoors(areUnlocked: Bool) {
        passengerDoorUnlock.alpha = areUnlocked ? 1.0 : 0.0
        lockIndicatorOn.alpha = areUnlocked ? 1.0 : 0.0
    }
    
    func doors(areUnlocked: Bool) {
        driversDoor(isUnlocked: areUnlocked)
        passengerDoors(areUnlocked: areUnlocked)
        lockIndicatorOn.alpha = areUnlocked ? 1.0 : 0.0
    }
    
    // MARK: - Fuel
    
    func fuelLevel(_ level: Int) {
        
        if (level > 0 && level < 21)
        {
            let image = UIImage(named: "fuel_gauge_fill_\(level)")
            self.fuelGauge.image = image
        }
    }
    
    // MARK: - Odemeter
    
    func odometer(mileage: Float) {
        
        let mileageString = String(format: "%0.1f", mileage)
        mileageLabel.text = mileageString
    }
    
    // MARK: - Indicators
    
    func tireIndicator(isOn: Bool) {
        tireIndicatorOn.alpha = isOn ? 1.0 : 0.0
    }
    
    func brakeIndicator(isOn: Bool) {
        brakeIndicatorOn.alpha = isOn ? 1.0 : 0.0
    }
    
    func engineIndicator(isOn: Bool) {
        engineIndicatorOn.alpha = isOn ? 1.0 : 0.0
    }
    
    func oilIndicator(isOn: Bool) {
        oilIndicatorOn.alpha = isOn ? 1.0 : 0.0
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

    func setSpeed(speed: Int) {
        
        let value: Float = Float(speed) / Float(120.0)
        speedometer.value = value
        
        if (speed == 0)
        {
            setGear(gear: .park)
        }
        else
        {
            setGear(gear: .drive)
        }
    }
    
    @objc func speedometerChanged(_ sender: MTCircularSlider) {
        speedLabel.text = String(Int(speedometer.value * 120))
    }
    
    // MARK: - Setup

    private func setBoldLabels() {
        
        mileageLabel.font = UIFont(name: "EurostileBold", size: 36.0)
        timeLabel.font = UIFont(name: "EurostileBold", size: 36.0)
    }

    private func startClock() {
        clockTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdated), userInfo: nil, repeats: true)
    }
    
    @objc private func timerUpdated() {
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
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        
        if (self.engineIsOn)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.engineIsOn = false
                self.turnOff(animated: true)
            })
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.engineIsOn = true
                self.turnOn(animated: true)
            })
        }
    }
    
    private func initFuel() {
        
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
                self.initFuel()
            })
        }
    }
    
    private func initTemp() {
        
        if (tempLevel < 10)
        {
            tempLevel += 1
            
            let imageName = "temp_gauge_fill_\(tempLevel)"
            let image = UIImage(named: imageName)
            self.tempGauge.image = image
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.initTemp()
            })
        }
    }
    
    private var increment: Float = 0.009
    private var initSpeedometerTimer = Timer()
    
    private func initSpeedometer() {
        initSpeedometerTimer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        
        speedometer.value += increment
        
        if (speedometer.value >= speedometer.valueMaximum) {
            increment = -increment
        }
        else if (speedometer.value <= speedometer.valueMinimum)
        {
            initSpeedometerTimer.invalidate()
            speedometer.addTarget(self, action: #selector(speedometerChanged(_:)), for: .valueChanged)
            increment = -increment
        }
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

