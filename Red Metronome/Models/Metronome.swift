//
//  Metronome.swift
//  Red Metronome
//
//  Created by Alexander Nagel on 13.03.21.
//

import Foundation
import UIKit
import AVFoundation

protocol MetronomeDelegate {
    func updateUI()
}

class Metronome {
    
    var delegate: MetronomeDelegate?
    
    var audioPlayerNode:AVAudioPlayerNode
    var audioFile:AVAudioFile
    var audioEngine:AVAudioEngine
    
    var player: AVAudioPlayer!
    
    var bpm: Double = 120
    var isPlaying = false
    
    
    var aboluteTimeOfFirstBeat = TimeInterval(0)
    var timeofNextBeat = TimeInterval(0)
    var durationOfOneBeat = 0.0
    var ticksPerBeat = 0
    var durationOfOneTick = 0.0
    var targetRange: ClosedRange<Double> = 0.0...0.0
    var targetRangeSize = 0.0
    var ticksCounter = 0
    var currentBar: Int = 1
    var beatsInBar: Int = 4
    var currentBeat: Int = 0 {
        didSet {
            delegate?.updateUI()
        }
    }
    
    var timer = Timer()
    
    var bpmDetector = BpmDetector()
    
    init (fileURL: URL) {
        
        audioPlayerNode = AVAudioPlayerNode()
        // https://developer.apple.com/documentation/avfaudio/avaudioplayernode
        
        audioFile = try! AVAudioFile(forReading: fileURL)
        audioEngine = AVAudioEngine()
        
        audioEngine.attach(self.audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        do {
            try audioEngine.start()
            
            // now done in AppDelegate.swift!
            // try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            // try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        audioPlayerNode.stop()
        timer.invalidate()
        isPlaying = false
        //totalDeviation = 0
        currentBeat = 0
        currentBar = 1
        ticksCounter = 0
    }
    
    func increaseBpm(by increment: Double) {
        if bpm + increment <= K.bpmRange.upperBound {
            bpm = bpm + increment
            if isPlaying {
                stop()
                //play(bpm: bpm)
                playUsingTimer(bpm: bpm)
            }
        }
    }
    
    func decreaseBpm(by decrement: Double) {
        if bpm + decrement >= K.bpmRange.lowerBound {
            bpm = bpm - decrement
            if isPlaying {
                stop()
                //play(bpm: bpm)
                playUsingTimer(bpm: bpm)
            }
        }
    }
    
    func setBpm(to newTempo: Double) {
        let validBpmRange = 40.0...400.0
        if validBpmRange.contains(newTempo) {
            bpm = newTempo
            if isPlaying {
                stop()
                //play(bpm: bpm)
                playUsingTimer(bpm: bpm)
            }
        }
    }
    
    func createBuffer(forBpm bpm: Double) -> AVAudioPCMBuffer {
        
        audioFile.framePosition = 0
        
        let durationOfOneBeat = K.secondsPerMinute / bpm
        let sampleRate = audioFile.processingFormat.sampleRate
        let periodLength = AVAudioFrameCount(sampleRate * durationOfOneBeat)
        
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: periodLength)
        
        do {
            try audioFile.read(into: buffer!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        buffer?.frameLength = periodLength
        
        return buffer!
    }
    
    func play(bpm: Double) {
        
        let buffer = createBuffer(forBpm: bpm)

//
        self.audioPlayerNode.play()
        
        // https://developer.apple.com/documentation/avfoundation/avaudioplayernode/1388422-schedulebuffer
        // https://developer.apple.com/documentation/avfaudio/avaudioplayernode/1388422-schedulebuffer
        
        //
        // start to loop
        //
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
        
        isPlaying = true
    }
    
    func playSingleClick(bpm: Double) {
        
        let buffer = createBuffer(forBpm: bpm)
        
        
        // https://developer.apple.com/documentation/avfoundation/avaudioplayernode/1388422-schedulebuffer
        // https://developer.apple.com/documentation/avfaudio/avaudioplayernode/1388422-schedulebuffer
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        self.audioPlayerNode.play()
        isPlaying = true
    }
    
    func playUsingTimer (bpm: Double) {
        
        let buffer = createBuffer(forBpm: bpm)
        
                print(buffer.frameLength)
                print(buffer.format)
                print(buffer.floatChannelData ?? 0)
        
        self.audioPlayerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    
        //
        // play first sound
        //
        audioPlayerNode.play()
        currentBeat += 1
        
        isPlaying = true
        
        //
        // set up
        //
        aboluteTimeOfFirstBeat = Date().timeIntervalSince1970
        durationOfOneBeat = K.secondsPerMinute / bpm
        timeofNextBeat = Double(currentBeat) * durationOfOneBeat
        ticksPerBeat = K.ticksPerBeat
        durationOfOneTick = durationOfOneBeat / Double(ticksPerBeat)
        
        //
        // set up tolerance range to +- 1/2 tick of next beat
        //
        targetRange = (timeofNextBeat - 0.5 * durationOfOneTick)...(timeofNextBeat + 0.5 * durationOfOneTick)
        targetRangeSize = targetRange.upperBound - targetRange.lowerBound
        
//        print("-------")
//        print("setup: ")
//        print("-------")
//        print("bpm = \(bpm)")
//        print("aboluteTimeOfFirstBeat = \(aboluteTimeOfFirstBeat)")
//        print("durationOfOneBeat = \(durationOfOneBeat)")
//        print("timeofNextBeat = \(timeofNextBeat)")
//        print("toleranceRange = \(targetRange)")
//        print("durationOfOneTick = \(durationOfOneTick)")
        
        //
        // start timer
        //
        timer = Timer.scheduledTimer(timeInterval: durationOfOneTick, target: self, selector: #selector(self.playClick), userInfo: nil, repeats: true)
    }
    

    
    @objc func playClick() {
        
        //
        // playSound(soundName: K.metronomeSoundFileName, type: K.metronomeSoundFileType)
        //
        
        audioPlayerNode.play()
        
 //       print("--------------------------------------")
 //       print("tick: ")
 //       print("--------------------------------------")
        
        ticksCounter += 1
        
        //
        // compute time difference in ms to time1 to now
        //
        let now = Date().timeIntervalSince1970
        var currentTimePassed = (now - aboluteTimeOfFirstBeat)
        
  //      print("tick \(ticksCounter) \(currentTimePassed)")
  //      print("toleranceRange = \(toleranceRange)")
        
        if targetRange.contains(currentTimePassed) {
            
            //
            // play click sound
            //
            playSound(soundName: "tone")
            
            //
            // compute deviation from target time
            //
            let deviation = -(timeofNextBeat - currentTimePassed)
                      
//            print()
//            print("--------------------------------------")
//            print("\(bpm) BPM - Beat \(currentBeat) / \(beatsInBar) - Bar \(currentBar)")
//            print("--------------------------------------")
//            print("\(ticksCounter) ticks of \(round(durationOfOneTick * 1000, toDigits: 1)) ms")
//            print("currentTimePassed = \(currentTimePassed) s in total")
//            print("Target range = \(targetRange) s")
//            print("Target range size = \(targetRangeSize) s")
//            print("Deviation from target (\(timeofNextBeat) s): \(round(deviation * 1000, toDigits: 1)) ms")
            //print("ticks = \(ticksCounter)")
            //
            // prepare next beat
            //
            currentBeat += 1
            if currentBeat > beatsInBar {
                currentBar += 1
            }
            currentBeat = ((currentBeat - 1) % beatsInBar) + 1 // count always from 1 to beatsInBar
            currentTimePassed = 0.0
            timeofNextBeat += durationOfOneBeat
            ticksCounter = 0
            targetRange = (timeofNextBeat - 0.5 * durationOfOneTick)...(timeofNextBeat + 0.5 * durationOfOneTick)
            targetRangeSize = targetRange.upperBound - targetRange.lowerBound
            
            
            
            
            
        }
        //audioPlayerNode.stop()
    }
    
    func playSound(soundName: String) {
        let url = Bundle.main.url(forResource: soundName, withExtension: "wav")
        player = try! AVAudioPlayer(contentsOf: url!)
        player.play()
        
    }
    
    func round (_ input: Double, toDigits digits: Int) -> Double {
        
        return Double(String(format: "%0.\(digits)f", input)) ?? 0
    }    
}
