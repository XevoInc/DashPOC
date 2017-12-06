//
//  ViewController.swift
//  Cluster
//
//  Created by Mario Bragg on 11/30/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    @IBOutlet weak var fuelGauge: UIImageView!
    @IBOutlet weak var speedometer: UIImageView!
    @IBOutlet weak var speedometerMask: UIImageView!
    //@IBOutlet weak var speedometerMask: AngleGradientBorderView!
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
    
    private var clockTimer: Timer?
    
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
        
        tireIndicator(isOn: false)
        brakeIndicator(isOn: false)
        engineIndicator(isOn: false)
        oilIndicator(isOn: false)
        
        setGear(gear: .drive)
        //setSpeed(speed: 80)
        //setupSpeedometer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSpeed(speed: 80)
        //rotateView()
    }
    
    // MARK: - Indicators
    
    func tireIndicator(isOn: Bool) {
        tireIndicatorOn.isHidden = !isOn
    }
    
    func brakeIndicator(isOn: Bool) {
        brakeIndicatorOn.isHidden = !isOn
    }
    
    func engineIndicator(isOn: Bool) {
        engineIndicatorOn.isHidden = !isOn
    }
    
    func oilIndicator(isOn: Bool) {
        oilIndicatorOn.isHidden = !isOn
    }
    
    // MARK: - Set Gear
    
    func setGear(gear: Gear) {
        
        parkGearOn.isHidden = true
        reverseGearOn.isHidden = true
        neutralGearOn.isHidden = true
        driveGearOn.isHidden = true
        lowGearOn.isHidden = true
        
        switch gear {
            case .park:
                parkGearOn.isHidden = false
            case .reverse:
                reverseGearOn.isHidden = false
            case .neutral:
                neutralGearOn.isHidden = false
            case .drive:
                driveGearOn.isHidden = false
            case .low:
                lowGearOn.isHidden = false
        }
    }
    
    // MARK: - Set Speed
    
    func setSpeed(speed: Int) {

        //speedometerMask.alpha = 1.0
        
        if (speed <= 60)
        {
            //speedometerMask.image = UIImage(named: "ic_speedometer_mask1")
            //speedometer.mask = speedometerMask
        }
        else if (speed > 60 && speed <= 120)
        {
            //speedometerMask.image = UIImage(named: "ic_speedometer_mask2")
            //speedometer.mask = speedometerMask
        }
        
        //40 mph = 90 deg
        let deg: CGFloat = 2.25
        
        let angle =  CGFloat(CGFloat(speed) * deg * CGFloat(Double.pi / 180))
        let tr = CGAffineTransform.identity.rotated(by: angle)
        speedometer.transform = tr
        

        
//        UIView.animate(withDuration: 1.0, animations: {
//            self.speedometer.transform = tr
//        }, completion: { (finished) in
//
//        })
        
        speedLabel.text = String(speed)
    }
    
    // MARK: - Setup
    
//    func setupSpeedometer() {
//        
//        let speedometerGradientColors: [AnyObject] = [
//    //            UIColor(red: 56.0/255.0, green: 229.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor,
//    //            UIColor(red: 56.0/255.0, green: 229.0/255.0, blue: 255.0/255.0, alpha: 0.1).cgColor
//            UIColor.red.withAlphaComponent(1.0).cgColor,
//            UIColor.red.withAlphaComponent(0.1).cgColor
//        ]
//
//        speedometerMask.setupGradientLayer(borderColors: speedometerGradientColors, borderWidth: 44)
//    }
    
//    func rotateView() {
//        let animation = CABasicAnimation(keyPath: "transform.rotation")
//        animation.fromValue = 0
//        animation.toValue = 2.0 * M_PI
//        animation.duration = 3
//        animation.isRemovedOnCompletion = true
//        animation.delegate = self
//        animation.setValue("spin", forKey: "animationId")
//        speedometerMask.layer.add(animation, forKey: "spin")
//    }

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
        let displayHour = hour < 13 ? hour : hour - 12
        
        let minutes = calendar.component(.minute, from: date)
        var minutesString = String(minutes)
        if (minutes < 10)
        {
            minutesString = "0" + minutesString
        }
        
        self.timeLabel.text = "\(displayHour):" + minutesString
        self.pmLabel.text = hour < 13 ? "AM" : "PM"
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

