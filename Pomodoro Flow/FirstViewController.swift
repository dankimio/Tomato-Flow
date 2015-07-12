//
//  TimerViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!

    // Timer
    private var timerEnabled = false
    
    // Configuration
    private let rowsPerSection = 7
    private let animationDuration = 0.3
    private let settings = SettingsManager.sharedManager
    
    private struct CollectionViewIdentifiers {
        static let emptyCell = "EmptyCell"
        static let filledCell = "FilledCell"
    }
    
    // Pomodoros view
    private var completedPomodoros = 9
    private var targetPomodoros: Int
    
    // MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        targetPomodoros = settings.targetPomodoros
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe settings to update views
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "refreshPomodoros", name: "targetPomodorosUpdated", object: nil)
    }
    
    // MARK: - Actions
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
    
    // MARK: - Helper methods
    func refreshPomodoros() {
        targetPomodoros = settings.targetPomodoros
        collectionView.reloadData()
    }

    private func toggleButtons() {
        toggleStartButton()
        toggleButtonContainer()
    }
    
    private func toggleStartButton() {
        let newAlpha: CGFloat = 1 * (timerEnabled ? 0 : 1)
        
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = newAlpha
        }
    }
    
    private func toggleButtonContainer() {
        let deltaY: CGFloat = 54 * (timerEnabled ? -1 : 1)
        
        UIView.animateWithDuration(animationDuration) {
            self.buttonContainer.frame.origin.y += deltaY
            self.buttonContainer.hidden = !self.buttonContainer.hidden
        }
    }
    
    private func numberOfSections() -> Int {
        return Int(ceil(Double(targetPomodoros) / Double(rowsPerSection)))
    }
    
    private func lastSectionIndex() -> Int {
        if numberOfSections() == 0 {
            return 0
        }
        
        return numberOfSections() - 1
    }
    
    private func numberOfRowsInLastSection() -> Int {
        return targetPomodoros % rowsPerSection
    }
}

// MARK: - UICollectionViewDataSource
extension TimerViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if targetPomodoros - section * rowsPerSection >= rowsPerSection {
            return rowsPerSection
        } else {
            return numberOfRowsInLastSection()
        }
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if rowsPerSection * indexPath.section + indexPath.row < completedPomodoros {
                return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.filledCell,
                    forIndexPath: indexPath)
            } else {
                return collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewIdentifiers.emptyCell,
                    forIndexPath: indexPath)
            }
    }
}

// MARK: - UICollectionViewDelegate
extension TimerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            // Set insets on last row only and skip if section is full
            if section != lastSectionIndex() || numberOfRowsInLastSection() == 0 {
                return UIEdgeInsetsMake(0, 0, 12, 0)
            }
            
            // Cell width + cell spacing
            let cellWidth = 30 + 14
            let inset = (collectionView.frame.width - CGFloat(numberOfRowsInLastSection() * cellWidth)) / 2.0
            
            return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}

