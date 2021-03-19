//
//  ViewController.swift
//  Red Metronome
//
//  Created by Alexander Nagel on 19.03.21.
//
// https://stackoverflow.com/questions/47646712/metronome-with-accents-in-swift-4-using-avaudioengine

let DEBUG = false

import UIKit
import SwiftUI

class ViewController: UIViewController, MetronomeDelegate {
    
    var metronome: Metronome
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    
    @IBOutlet weak var bpmTextField: UITextField!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var minus10Button: UIButton!
    @IBOutlet weak var minus1Button: UIButton!
    @IBOutlet weak var plus1Button: UIButton!
    @IBOutlet weak var plus10Button: UIButton!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var playStopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = [minus10Button, minus1Button, plus1Button, plus10Button, tapButton, playStopButton]
        for button in buttons {
            button?.showsTouchWhenHighlighted = true
            button?.isEnabled = true
            button?.isSelected = false
            button?.isHidden = false
            button?.backgroundColor = K.Color.ruby_red
            button?.setTitleColor(K.Color.cultured, for: .normal)
        }
        bpmLabel.backgroundColor = K.Color.cultured
        bpmLabel.textColor = K.Color.ruby_red
        
        updateUI()
    }
    
    //    init(handler: Metronome) {
    //        handler.delegate = self
    //    }
    //
    
    required init?(coder aDecoder: NSCoder) {
        
        // create metronome object
        let fileUrl = Bundle.main.url(forResource: K.metronomeSoundFileName, withExtension: K.metronomeSoundFileType)
        metronome = Metronome(fileURL: fileUrl!)
        
        
        
        
        // call super class's method
        super.init(coder: aDecoder)
        
        metronome.delegate = self
    }
    
    @IBAction func playStopButtonPressed(_ sender: UIButton) {
        
        if !metronome.isPlaying {
            //metronome.playSingleClick(bpm: metronome.bpm)
            //metronome.play(bpm: metronome.bpm)
            metronome.playUsingTimer(bpm: metronome.bpm)
            
        } else {
            metronome.stop()
        }
        updateUI()
    }
    
    @IBAction func tapButtonPressed(_ sender: UIButton) {
        
        metronome.stop()
        
        let newBpm = metronome.bpmDetector.tapReceived()
        metronome.setBpm(to: newBpm)
        
        updateUI()
    }
    
    @IBAction func plus1ButtonPressed(_ sender: UIButton) {
        metronome.increaseBpm(by: 1)
        updateUI()
    }
    
    @IBAction func plus10ButtonPressed(_ sender: UIButton) {
        metronome.increaseBpm(by: 10)
        updateUI()
    }
    @IBAction func minus1ButtonPressed(_ sender: UIButton) {
        metronome.decreaseBpm(by: 1)
        updateUI()
    }
    
    @IBAction func minus10ButtonPressed(_ sender: UIButton) {
        metronome.decreaseBpm(by: 10)
        updateUI()
    }
    
    
    
    
    func updateUI() {
        
        
        //
        // print current BMP value
        //
        bpmLabel.text = String(metronome.bpm)
        
        //
        // style PLAY / STOP button according to play / stop status
        //
        if metronome.isPlaying {
            playStopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            playStopButton.setImage(UIImage(systemName: "stop"), for: .highlighted)
            playStopButton.backgroundColor = K.Color.pastel_pink
        } else {
            playStopButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playStopButton.setImage(UIImage(systemName: "play"), for: .highlighted)
            playStopButton.backgroundColor = K.Color.ruby_red
        }
        
        //
        // update beat/bar display
        //
        for label in [label1, label2, label3, label4, label5, label6, label7, label8] {
            label?.backgroundColor = K.Color.quick_silver
            label?.textColor = K.Color.cultured
        }
        if metronome.isPlaying {
            label1.backgroundColor = (metronome.currentBeat == 1) ? K.Color.ruby_red : K.Color.quick_silver
            
            
            label2.backgroundColor = (metronome.currentBeat == 2) ? K.Color.ruby_red : K.Color.quick_silver
            
            
            label3.backgroundColor = (metronome.currentBeat == 3) ? K.Color.ruby_red : K.Color.quick_silver
            
            
            label4.backgroundColor = (metronome.currentBeat == 4) ? K.Color.ruby_red : K.Color.quick_silver
            
        }
        label8.text = String(metronome.ticksCounter)
    }
}

