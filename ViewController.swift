//
//  ViewController.swift
//  Lifesaber
//
//  Created by Samuel Zrna on 5/29/17.
//  Copyright © 2017 samgram. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    let saber1 = UIImage(named: "saber1")
    let saber2 = UIImage(named: "saber2")
    let handle = UIImage(named: "handle")

    var timer: Timer!
    var glowTimer: Timer!
    
    var sensativity = 1.3
    
    var turnOn:AVAudioPlayer = AVAudioPlayer()
    var turnOff:AVAudioPlayer = AVAudioPlayer()
    var deflect:AVAudioPlayer = AVAudioPlayer()
    var hit:AVAudioPlayer = AVAudioPlayer()
    var swing1:AVAudioPlayer = AVAudioPlayer()
    //var swing2:AVAudioPlayer = AVAudioPlayer()
    var switchListen:UISwitch = UISwitch()
    
    var glowBool = true
    var isSaberOn = false
    
    @IBOutlet weak var saberIV: UIButton!
    
    @IBAction func switchSaber(_ sender: Any) {
        if turnOn.currentTime == 0 || turnOn.volume == 0.0 {
            isSaberOn = true
            turnOn.currentTime = 0
            turnOn.setVolume(1.5, fadeDuration: 0.0)
            turnOn.play()
        } else {
            isSaberOn = false
            turnOn.setVolume(0.0, fadeDuration: 0.3)
            turnOff.play()
        }
    }
    
//    @IBAction func swingSlow(_ sender: Any) {
//        deflect.setVolume(0.0, fadeDuration: 0.3)
//        //hit.setVolume(0.0, fadeDuration: 0.3)
//        swing1.setVolume(0.0, fadeDuration: 0.1)
//
//        swing2.setVolume(3.0, fadeDuration: 0.0)
//        swing2.play()
//    }
    
    @IBAction func swingFast(_ sender: Any) {
        //deflect.setVolume(0.0, fadeDuration: 0.3)
        //hit.setVolume(0.0, fadeDuration: 0.3)
        //swing2.setVolume(0.0, fadeDuration: 0.1)
        
        swing1.setVolume(5.0, fadeDuration: 0.0)
        swing1.play()
    }
    
    @IBAction func deflectBtn(_ sender: Any) {
        //hit.setVolume(0.0, fadeDuration: 0.3)
        //swing1.setVolume(0.0, fadeDuration: 0.3)
        //swing2.setVolume(0.0, fadeDuration: 0.3)
        
        deflect.setVolume(1.0, fadeDuration: 0.0)
        deflect.play()
    }
    
    @IBAction func hitBtn(_ sender: Any) {
        deflect.setVolume(0.0, fadeDuration: 0.3)
        swing1.setVolume(0.0, fadeDuration: 0.3)
        //swing2.setVolume(0.0, fadeDuration: 0.3)
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        hit.setVolume(1.0, fadeDuration: 0.0)
        hit.play()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        glowTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateGlow), userInfo: nil, repeats: true)
        
        turnOn = self.getAudio(fileName: "turnOn", fileExt: "mp3")
        turnOff = self.getAudio(fileName: "turnOff", fileExt: "wav")
        deflect = self.getAudio(fileName: "deflect", fileExt: "wav")
        hit = self.getAudio(fileName: "hit", fileExt: "wav")
        swing1 = self.getAudio(fileName: "swing1", fileExt: "wav")
        //swing2 = self.getAudio(fileName: "swing2", fileExt: "wav")
    }
    
    // Gets a file name & extension and returns its AVAudioPlayer
    func getAudio(fileName: String, fileExt: String) -> AVAudioPlayer {
        do {
            let audioPath = Bundle.main.path(forResource: fileName, ofType: fileExt)
            return try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        } catch {}
        return AVAudioPlayer()
    }
    
    func updateGlow() {
        if isSaberOn {
            if glowBool {
                self.saberIV.setImage(saber1, for: saberIV.state)
                glowBool = false
            } else {
                self.saberIV.setImage(saber2, for: saberIV.state)
                glowBool = true
            }
        } else{
            self.saberIV.setImage(handle, for: saberIV.state)
        }
    }
    
    func update() {
        if isSaberOn {
            if let accelerometerData = motionManager.accelerometerData {
                switch sqrt(pow(accelerometerData.acceleration.x, 2.0) + pow(accelerometerData.acceleration.y, 2.0) + pow(accelerometerData.acceleration.z, 2.0)) {
                case (sensativity * 1.0)..<(sensativity * 2.2):
                    self.swingFast(swing1)
                case (sensativity * 2.4)..<(sensativity * 2.9):
                    self.deflectBtn(deflect)
                case (sensativity * 3.5)..<100:
                    self.hitBtn(hit)
                default:
                    print("The Force comes from within...")
                }
            }
            if let gyroData = motionManager.gyroData {
                switch sqrt(pow(gyroData.rotationRate.x, 2.0) + pow(gyroData.rotationRate.z, 2.0)) {
                case (sensativity * 2.0)..<(sensativity * 7.0):
                    self.swingFast(swing1)
                case (sensativity * 8.0)..<(sensativity * 10.0):
                    self.deflectBtn(deflect)
//                case (sensativity * 11.0)..<100:
//                    self.hitBtn(hit)
                default:
                    print("The Force comes from within...")
                }
            }
        }
    }
}
