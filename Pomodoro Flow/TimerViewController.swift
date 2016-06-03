//
//  TimerViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var unpauseButton: UIButton!
    @IBOutlet weak var buttonContainer: UIView!
    
    @IBOutlet weak var timerLabel: UILabel! {
        didSet {
            // Numbers are monospaced by default on iOS 8 and earlier
            if #available(iOS 9.0, *) {
                timerLabel.font = UIFont
                    .monospacedDigitSystemFontOfSize(124.0,
                                                     weight: UIFontWeightUltraLight)
            }
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!

    // Scheduler
    private let pomodoro = Pomodoro.sharedInstance

    // Time
    private var timer: NSTimer?
    private var currentTime: Double!

    // Configuration
    private let animationDuration = 0.3
    private let settings = Settings.sharedInstance

    private struct CollectionViewIdentifiers {
        static let emptyCell = "EmptyCell"
        static let filledCell = "FilledCell"
    }

    // MARK: - Initialization
    let viewModel = TimerViewModel()
    
    private let disposeBag = DisposeBag()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self,
                         selector: #selector(willEnterForeground),
                         name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.timerLabel
            .bindTo(timerLabel.rx_text)
            .addDisposableTo(disposeBag)
        
        viewModel.timerLabelColor
            .subscribeNext { self.timerLabel.textColor = $0 }
            .addDisposableTo(disposeBag)
        
        viewModel.pomodorosCount
            .asObservable()
            .subscribeNext { _ in self.collectionView.reloadData() }
            .addDisposableTo(disposeBag)
        
        viewModel.targetPomodorosCount
            .asObservable()
            .subscribeNext { _ in self.collectionView.reloadData() }
            .addDisposableTo(disposeBag)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        willEnterForeground()
    }

    func willEnterForeground() {
        print("willEnterForeground called from controller")
    }

    // MARK: - Actions

    @IBAction func start(sender: RoundedButton) {
        viewModel.start()
        animateStarted()
    }

    @IBAction func stop(sender: RoundedButton) {
        viewModel.stop()
        animateStopped()
    }
    
    @IBAction func pause(sender: EmptyRoundedButton) {
        viewModel.pause()
        togglePauseButton()
        animatePaused()
    }

    @IBAction func unpause(sender: EmptyRoundedButton) {
        viewModel.unpause()
        togglePauseButton()
        animateUnpaused()
    }
    
    func presentAlertFromNotification(notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle,
                                                message: notification.alertBody,
                                                preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default) { action in print("OK") }
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - Helpers
    
    private func togglePauseButton() {
        pauseButton.hidden = !pauseButton.hidden
        unpauseButton.hidden = !unpauseButton.hidden
    }

    private func animateStarted() {
        let deltaY: CGFloat = 54
        buttonContainer.frame.origin.y += deltaY
        buttonContainer.hidden = false

        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = 0.0
            self.buttonContainer.alpha = 1.0
            self.buttonContainer.frame.origin.y += -deltaY
        }
    }

    private func animateStopped() {
        UIView.animateWithDuration(animationDuration) {
            self.startButton.alpha = 1.0
            self.buttonContainer.alpha = 0.0
        }

        pauseButton.setTitle("Pause", forState: .Normal)
    }

    private func animatePaused() {
        pauseButton.setTitle("Resume", forState: .Normal)
    }

    private func animateUnpaused() {
        pauseButton.setTitle("Pause", forState: .Normal)
    }

}

extension TimerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return numberOfRows(inSection: section)
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let index = rowsPerSection * indexPath.section + indexPath.row
        let identifier = (index < viewModel.pomodorosCount.value) ?
            CollectionViewIdentifiers.filledCell : CollectionViewIdentifiers.emptyCell

        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier,
                                                                     forIndexPath: indexPath)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        let bottomInset: CGFloat = 12
        return UIEdgeInsetsMake(0, 0, bottomInset, 0)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10.0
    }
    
    // MARK: Helpers
    
    private var rowsPerSection: Int {
        let cellWidth: CGFloat = 30.0
        let margin: CGFloat = 10.0
        return Int(collectionView.frame.width / (cellWidth + margin))
    }
    
    private func numberOfRows(inSection section: Int) -> Int {
        if section == lastSectionIndex {
            return numberOfRowsInLastSection
        } else {
            return rowsPerSection
        }
    }
    
    private var numberOfRowsInLastSection: Int {
        if viewModel.targetPomodorosCount.value % rowsPerSection == 0 {
            return rowsPerSection
        } else {
            return viewModel.targetPomodorosCount.value % rowsPerSection
        }
    }
    
    private var numberOfSections: Int {
        return Int(ceil(Double(viewModel.targetPomodorosCount.value) / Double(rowsPerSection)))
    }
    
    private var lastSectionIndex: Int {
        if numberOfSections == 0 {
            return 0
        }
        
        return numberOfSections - 1
    }

}
