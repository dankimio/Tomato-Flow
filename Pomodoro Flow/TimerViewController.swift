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

  @IBOutlet weak var timerLabel: UILabel! {
    didSet {
      // Numbers are monospaced by default in iOS 8 and earlier
      if #available(iOS 9.0, *) {
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 124.0,
                                                           weight: UIFont.Weight.ultraLight)
      }
    }
  }

  @IBOutlet weak var collectionView: UICollectionView!

  // Scheduler
  fileprivate let scheduler: Scheduler
  fileprivate let pomodoro = Pomodoro.sharedInstance

  // Time
  fileprivate var timer: Timer?
  fileprivate var currentTime: Double!
  fileprivate var running = false

  // Configuration
  fileprivate let animationDuration = 0.3
  fileprivate let settings = SettingsManager.sharedManager

  fileprivate struct CollectionViewIdentifiers {
    static let emptyCell = "EmptyCell"
    static let filledCell = "FilledCell"
  }

  // Pomodoros view
  fileprivate var pomodorosCompleted: Int!
  fileprivate var targetPomodoros: Int

  // MARK: - Initialization

  required init?(coder aDecoder: NSCoder) {
    targetPomodoros = settings.targetPomodoros
    pomodorosCompleted = pomodoro.pomodorosCompleted
    scheduler = Scheduler()

    super.init(coder: aDecoder)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

   
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    willEnterForeground()
  }

    @objc func willEnterForeground() {
    print("willEnterForeground called from controller")

    setCurrentTime()
    updateTimerLabel()

    if scheduler.pausedTime != nil {
      animateStarted()
      animatePaused()
    }

    reloadData()
  }

    @objc func secondPassed() {
    if currentTime > 0 {
      currentTime = currentTime - 1.0
      updateTimerLabel()
      return
    }

    print("State: \(pomodoro.state), done: \(pomodoro.pomodorosCompleted)")

    if pomodoro.state == .default {
      pomodoro.completePomodoro()
      reloadData()
    } else {
      pomodoro.completeBreak()
    }

    stop()

    print("State: \(pomodoro.state), done: \(pomodoro.pomodorosCompleted)")
  }

  // MARK: - Actions

  @IBAction func togglePaused(_ sender: EmptyRoundedButton) {
    scheduler.paused ? unpause() :pause()
  }

  @IBAction func start(_ sender: RoundedButton) {
    start()
  }

  @IBAction func stop(_ sender: RoundedButton) {
    stop()
  }

  func start() {
    scheduler.start()
    running = true
    animateStarted()
    fireTimer()
  }

  func stop() {
    scheduler.stop()
    running = false
    animateStopped()
    timer?.invalidate()
    resetCurrentTime()
    updateTimerLabel()
  }

  func pause() {
    guard running else { return }

    scheduler.pause(currentTime)
    running = false
    timer?.invalidate()
    animatePaused()
  }

  func unpause() {
    scheduler.unpause()
    running = true
    fireTimer()
    animateUnpaused()
  }

  func presentAlertFromNotification(_ notification: UILocalNotification) {
    let alertController = UIAlertController(title: notification.alertTitle,
                                            message: notification.alertBody,
                                            preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { action in print("OK") }
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  // MARK: - Helpers

  fileprivate func reloadData() {
    targetPomodoros = settings.targetPomodoros
    pomodorosCompleted = pomodoro.pomodorosCompleted
    collectionView.reloadData()
  }

  fileprivate func updateTimerLabel() {
    let time = Int(currentTime)
    timerLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
  }

  fileprivate func setCurrentTime() {
    if let pausedTime = scheduler.pausedTime {
      currentTime = pausedTime
      return
    }

    if let fireDate = scheduler.fireDate {
      let newTime = fireDate.timeIntervalSinceNow
      currentTime = (newTime > 0 ? newTime : 0)
      return
    }

    resetCurrentTime()
  }

  fileprivate func resetCurrentTime() {
    switch pomodoro.state {
    case .default: currentTime = Double(settings.pomodoroLength)
    case .shortBreak: currentTime = Double(settings.shortBreakLength)
    case .longBreak: currentTime = Double(settings.longBreakLength)
    }
    resetTimerLabelColor()
  }

  fileprivate func resetTimerLabelColor() {
    switch pomodoro.state {
    case .default: timerLabel.textColor = UIColor.accentColor
    case .shortBreak, .longBreak: timerLabel.textColor = UIColor.breakColor
    }
  }

  fileprivate func fireTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1,
                                 target: self, selector: #selector(secondPassed), userInfo: nil, repeats: true)
  }

  fileprivate func refreshPomodoros() {
    targetPomodoros = settings.targetPomodoros
    collectionView.reloadData()
  }

  fileprivate func animateStarted() {
    let deltaY: CGFloat = 54
    buttonContainer.frame.origin.y += deltaY
    buttonContainer.isHidden = false

    UIView.animate(withDuration: animationDuration, animations: {
      self.startButton.alpha = 0.0
      self.buttonContainer.alpha = 1.0
      self.buttonContainer.frame.origin.y += -deltaY
    })
  }

  fileprivate func animateStopped() {
    UIView.animate(withDuration: animationDuration, animations: {
      self.startButton.alpha = 1.0
      self.buttonContainer.alpha = 0.0
    })

    pauseButton.setTitle("Pause", for: UIControl.State())
  }

  fileprivate func animatePaused() {
    pauseButton.setTitle("Resume", for: UIControl.State())
  }

  fileprivate func animateUnpaused() {
    pauseButton.setTitle("Pause", for: UIControl.State())
  }

}

extension TimerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: UICollectionViewDataSource

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections
  }

  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {

    return numberOfRows(inSection: section)
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let index = rowsPerSection * indexPath.section + indexPath.row
    let identifier = (index < pomodorosCompleted) ?
      CollectionViewIdentifiers.filledCell : CollectionViewIdentifiers.emptyCell

    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                              for: indexPath)
  }

  // MARK: UICollectionViewDelegate

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {

    let bottomInset: CGFloat = 12
    return UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10.0
  }

  // MARK: Helpers

  fileprivate var rowsPerSection: Int {
    let cellWidth: CGFloat = 30.0
    let margin: CGFloat = 10.0
    return Int(collectionView.frame.width / (cellWidth + margin))
  }

  fileprivate func numberOfRows(inSection section: Int) -> Int {
    if section == lastSectionIndex {
      return numberOfRowsInLastSection
    } else {
      return rowsPerSection
    }
  }

  fileprivate var numberOfRowsInLastSection: Int {
    if targetPomodoros % rowsPerSection == 0 {
      return rowsPerSection
    } else {
      return targetPomodoros % rowsPerSection
    }
  }

  fileprivate var numberOfSections: Int {
    return Int(ceil(Double(targetPomodoros) / Double(rowsPerSection)))
  }

  fileprivate var lastSectionIndex: Int {
    if numberOfSections == 0 {
      return 0
    }

    return numberOfSections - 1
  }

}
