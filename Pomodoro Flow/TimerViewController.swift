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
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!

    // Timer
    private var timerEnabled = false
    private var scheduledFor: NSDate?
    private var timer: NSTimer?
    private var notification = UILocalNotification()
    
    private var paused: Bool {
        get { return pausedTime > 0 }
        set {
            if newValue == true {
                pausedTime = currentTime
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("pausedTime")
            }
        }
    }
    
    private var pausedTime: Int {
        get { return NSUserDefaults.standardUserDefaults().integerForKey("pausedTime") }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "pausedTime") }
    }
    
    private var currentTime: Int! {
        didSet { formatTime() }
    }
    
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
        
        let app = UIApplication.sharedApplication()
        if let localNotification = app.scheduledLocalNotifications?.first, fireDate = localNotification.fireDate {
            currentTime = Int(fireDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970)
            fireTimer()
        } else if pausedTime > 0 {
            currentTime = pausedTime
            startButton.hidden = true
            buttonContainer.hidden = false
            pauseButton.setTitle("Resume", forState: .Normal)
        } else {
            currentTime = settings.pomodoroLength * 60
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        print(UIApplication.sharedApplication().scheduledLocalNotifications)
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("pausedTime")
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("paused")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        invalidateTimer()
    }
    
    // MARK: - Actions
    @IBAction func togglePaused(sender: EmptyRoundedButton) {
        print("togglePaused called")
        
        if paused {
            // Resume
            currentTime = pausedTime
            paused = false
            fireTimer()
            sender.setTitle("Pause", forState: .Normal)
            setupPomodoroNotification(Double(pausedTime))
        } else {
            // Pause
            paused = true
            invalidateTimer()
            sender.setTitle("Resume", forState: .Normal)
            cancelNotification()
        }
    }

    @IBAction func start(sender: RoundedButton) {
        print("Timer started")

        timerEnabled = true
        toggleButtons()
        
        fireTimer()
        setupPomodoroNotification(settings.pomodoroLengthInterval)
    }
    
    @IBAction func stop(sender: RoundedButton) {
        timerEnabled = false
        toggleButtons()
        
        invalidateTimer()
        cancelNotification()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("pausedTime")
        currentTime = settings.pomodoroLength * 60
    }
    
    // MARK: - Helper methods
    func updateTimerLabel() {
        currentTime = currentTime - 1
    }
    
    func fireTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self, selector: "updateTimerLabel", userInfo: nil, repeats: true)
        print("Timer fired")
    }
    
    func invalidateTimer() {
        if let timer = timer {
            if timer.valid {
                timer.invalidate()
                print("Timer invalidated")
            }
        }
    }
    
    func setupPomodoroNotification(interval: Double) {
        notification.fireDate = NSDate(timeIntervalSinceNow: Double(settings.pomodoroLength * 60))
        notification.alertTitle = "Pomodoro Finished!"
        notification.alertBody = "Time to take a break"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        print("Pomodoro notification created")
    }
    
    func cancelNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    func formatTime() {
        timerLabel.text = String(format: "%02d:%02d", currentTime / 60, currentTime % 60)
    }
    
    func refreshPomodoros() {
        targetPomodoros = settings.targetPomodoros
        collectionView.reloadData()
    }

    private func toggleButtons() {
        toggleStartButton()
        toggleButtonContainer()
    }
    
    private func toggleStartButton() {
        let newAlpha: CGFloat = startButton.alpha == 0.0 ? 1 : 0
        
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = newAlpha
        }
    }
    
    private func toggleButtonContainer() {
//        let deltaY: CGFloat = 54 * (timerEnabled ? 1 : -1)
//        buttonContainer.frame.origin.y += deltaY
        
        UIView.animateWithDuration(animationDuration) {
//            self.buttonContainer.frame.origin.y += -deltaY
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

