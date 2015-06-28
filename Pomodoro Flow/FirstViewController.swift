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
    
    @IBOutlet weak var collectionView: UICollectionView!

    var timerEnabled = false
    let animationDuration = 0.3
    
    var completedPomodoros = 3
    let targetPomodoros = 7
    
    struct CollectionViewIdentifiers {
        static let emptyCell = "EmptyCell"
        static let filledCell = "FilledCell"
    }
    
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
        
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = newAlpha
        }
    }
    
    func toggleButtonContainer() {
        let deltaY: CGFloat = 54 * (timerEnabled ? -1 : 1)
        
        UIView.animateWithDuration(animationDuration) {
            self.buttonContainer.frame.origin.y += deltaY
            self.buttonContainer.hidden = !self.buttonContainer.hidden
        }
    }
}

// MARK: - UICollectionViewDataSource
extension FirstViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return targetPomodoros
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell

        if indexPath.row < completedPomodoros {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.filledCell, forIndexPath: indexPath) as! UICollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.emptyCell, forIndexPath: indexPath) as! UICollectionViewCell
        }
        
        return cell
    }
}

