//
//  BpmDetector.swift
//  Red Metronome
//
//  Created by Alexander Nagel on 14.03.21.
//

import Foundation

class BpmDetector {
    
    var timer = Timer()
    var timeOfLastTap = TimeInterval()
    var bpmArray = [Double]()
    var currentAverageBpm: Double? = 120.0
    
    
    func tapReceived() -> Double {
        
        //
        // record current time
        //
        let now = Date().timeIntervalSince1970
        
        //
        // compute time difference in ms to timeOfLastTap
        //let timePassed = round((now - timeOfLastTap) * 1000, toDigits: 2)// measured in ms
        //
        let timePassed = (now - timeOfLastTap) * 1000// measured in ms

        //
        // compute current BPM
        //let currentBpm = round(60.0 / (timePassed / 1000), toDigits: 2) // current BPM
        //
        let currentBpm = 60.0 / (timePassed / 1000) // current BPM

        //
        // save current time in timeOfLastTap
        //
        timeOfLastTap = now
        
        //
        // if user pauses over 2 seconds or tempo is over 400 BPM: flush cache!
        //
        if timePassed > 2000 || timePassed < 150 {
            
            //
            //print("TIME OUT! cache cleared!")
            //
            clearCache()
        
        } else {
            
            //
            // add new Value to BPM array
            //
            updateArray(currentBpm)
            if DEBUG { print("bpmArray = \(bpmArray)") }
            
            //
            // compute average BPM from BPM array
            //
            currentAverageBpm = computeAverageBpm()
            if DEBUG { print("newAverage = \(currentAverageBpm ?? 0)") }
            
            if let currentAverageBpmUnwrapped = currentAverageBpm{
                if !currentAverageBpmUnwrapped.isNaN {
                    if DEBUG { print(#function) }
                    return round(currentAverageBpmUnwrapped, toDigits:0)
                    
                } else {
                    return 0
                }
            }
        }
        return 0
        
    }
    
    
    func clearCache() {
        
        if DEBUG { print("clearCache()") }
    
        bpmArray = []
    }
    
    func updateArray(_ currentBpm: Double) {
        
        if bpmArray.isEmpty {
            
            //
            // if no values there, add new value to array
            //
            bpmArray.append(currentBpm)
            
        } else { // if array has values ...
            
            //
            // if no currentAverageBpm exists, skip sanity check
            //
            if currentAverageBpm == nil {
                bpmArray.append(currentBpm)
            } else {
                
                //
                // if currentAverageBpm exists ...
                //
                if let currentAverageBpmUnwrapped = currentAverageBpm {
                    
                    //
                    // if new value is too different, reset cache
                    //
                    if currentBpm < (1 - K.BpmDtctr.tapTolerance) * currentAverageBpmUnwrapped || currentBpm > (1 + K.BpmDtctr.tapTolerance) * currentAverageBpmUnwrapped {
                        
                        clearCache()
                        
                    } else {
                        
                        //
                        // value fits! add it to array
                        //
                        let roundedValue = round(currentBpm, toDigits: 0)
                        if DEBUG { print("roundedValue = \(roundedValue)") }
                        bpmArray.append(roundedValue)
                        
                        //
                        // make sure, array doesn't exceed its max size
                        //
                        if bpmArray.count > K.BpmDtctr.bpmArrayMaxSize {
                            //print("-G-")
                            let firstDropped = bpmArray.dropFirst()
                            bpmArray = Array(firstDropped)
                        }
                    }
                }
            }
        }
    }
    
    func computeAverageBpm() -> Double {
        
        let sumOfBpms = bpmArray.reduce(0,+)
        let numberOfElements = bpmArray.count
        let averageBpm = round(sumOfBpms / Double(numberOfElements), toDigits: 2)
        return averageBpm
    }
    
    func round (_ input: Double, toDigits digits: Int) -> Double {
        
        return Double(String(format: "%0.\(digits)f", input)) ?? 0
    }    
}
