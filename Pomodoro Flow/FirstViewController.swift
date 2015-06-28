//
//  FirstViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    
    var timerEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pause(sender: RoundedButton) {
    }

    @IBAction func start(sender: RoundedButton) {
        timerEnabled = true
        toggleButtons()
    }
    
    @IBAction func stop(sender: RoundedButton) {
        timerEnabled = false
        toggleButtons()
    }
    
    func toggleButtons() {
        toggleStartButton()
        toggleButtonContainer()
    }
    
    func toggleStartButton() {
        let newAlpha: CGFloat = 1 * (timerEnabled ? 0 : 1)
        let newValue = !self.startButton.hidden
        
        UIView.animateWithDuration(0.3) {
            self.startButton.alpha = newAlpha
        }
    }
    
    func toggleButtonContainer() {
        let deltaY: CGFloat = 54 * (timerEnabled ? -1 : 1)
        
        UIView.animateWithDuration(0.3) {
            self.buttonContainer.frame.origin.y += deltaY
            self.buttonContainer.hidden = !self.buttonContainer.hidden
        }
    }
}

