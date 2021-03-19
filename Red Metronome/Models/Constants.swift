//
//  Constants.swift
//  Red Metronome
//
//  Created by Alexander Nagel on 14.03.21.
//

import Foundation
import UIKit

struct K {
    
    struct BpmDtctr {
        static let bpmArrayMaxSize = 50 // BPM is calculated from the last 20 values
        static let tapTolerance = 0.2 // if tap tempo varie more than 20%, a new measurement begins
        static let tapDetectionRange = 40.0...400.0
    }
    
    static let secondsPerMinute = 60.0
    static let metronomeSoundFileName = "tone"
    static let metronomeSoundFileType = "wav"
    static let bpmRange = 40.0...400.0
    static let ticksPerBeat = 10
    static let targetIntervalPercentage = 1
    
    struct Color {
        static let eerie_black = UIColor(red: 35/255, green: 37/255, blue: 36/255, alpha: 1)
        static let quick_silver = UIColor(red: 157/255, green: 162/255, blue: 164/255, alpha: 1);
        static let ruby_red = UIColor(red: 159/255, green: 5/255, blue: 31/255, alpha: 1);
        
        static let pastel_pink = UIColor(red: 219/255, green: 163/255, blue: 165/255, alpha: 1);
        static let cultured = UIColor(red: 247/255, green: 247/255, blue: 245/255, alpha: 1);
    }
    //
    // colors generated here: // https://coolors.co
    // blue e1f2fb
    // lightBlue f1f9f9
    // lightPink f3dfe3
    // pink e9b2bc
}



