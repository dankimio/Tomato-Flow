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
    
    var completedPomodoros = 9
    let targetPomodoros = 14
    let itemsPerSection = 7
    
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
    
    private func numberOfSections() -> Int {
        return Int(ceil(Double(targetPomodoros) / Double(itemsPerSection)))
    }
    
    private func lastSectionIndex() -> Int {
        if numberOfSections() == 0 {
            return 0
        }
        
        return numberOfSections() - 1
    }
    
    private func numberOfRowsInLastSection() -> Int {
        return targetPomodoros % itemsPerSection
    }
}

// MARK: - UICollectionViewDataSource
extension FirstViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if targetPomodoros - section * itemsPerSection >= itemsPerSection {
            return itemsPerSection
        } else {
            return targetPomodoros % itemsPerSection
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if itemsPerSection * indexPath.section + indexPath.row < completedPomodoros {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.filledCell, forIndexPath: indexPath) as! UICollectionViewCell
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.emptyCell, forIndexPath: indexPath) as! UICollectionViewCell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FirstViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        // Number of cells in the last section
        let cellsInSection = targetPomodoros % itemsPerSection
        
        // Set insets on last row only and skip if section is full
        if section != lastSectionIndex() || cellsInSection == 0 {
            return UIEdgeInsetsMake(0, 0, 12, 0)
        }

        // Cell width + cell spacing
        let cellWidth = 30 + 14
        var inset = (collectionView.frame.width - CGFloat(cellsInSection * cellWidth)) / 2.0
        
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

