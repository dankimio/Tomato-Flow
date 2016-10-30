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
      timerLabel.font = UIFont
        .monospacedDigitSystemFont(ofSize: 124.0, weight: UIFontWeightUltraLight)
    }
  }

  @IBOutlet weak var collectionView: UICollectionView!

  // Scheduler
  fileprivate let pomodoro = Pomodoro.sharedInstance

  // Time
  fileprivate var timer: Timer?
  fileprivate var currentTime: Double!

  // Configuration
  fileprivate let animationDuration = 0.3
  fileprivate let settings = Settings.sharedInstance

  fileprivate struct CollectionViewIdentifiers {
    static let emptyCell = "EmptyCell"
    static let filledCell = "FilledCell"
  }

  // MARK: - Initialization
  let viewModel = TimerViewModel()

  fileprivate let disposeBag = DisposeBag()

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default
      .addObserver(self,
                   selector: #selector(willEnterForeground),
                   name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

    bindViewModel()
  }

  fileprivate func bindViewModel() {
    viewModel.timerLabel
      .bindTo(timerLabel.rx.text)
      .addDisposableTo(disposeBag)

    viewModel.timerLabelColor
      .subscribe(onNext: {
        self.timerLabel.textColor = $0
      })
      .addDisposableTo(disposeBag)

    viewModel.pomodorosCount
      .asObservable()
      .subscribe(onNext: { _ in self.collectionView.reloadData() })
      .addDisposableTo(disposeBag)

    viewModel.targetPomodorosCount
      .asObservable()
      .subscribe(onNext: { _ in self.collectionView.reloadData() })
      .addDisposableTo(disposeBag)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    willEnterForeground()
  }

  func willEnterForeground() {
    print("willEnterForeground called from controller")
  }

  func pause() {
    viewModel.pause()
    togglePauseButton()
    animatePaused()
  }

  // MARK: - Actions

  @IBAction func start(_ sender: RoundedButton) {
    viewModel.start()
    animateStarted()
  }

  @IBAction func stop(_ sender: RoundedButton) {
    viewModel.stop()
    animateStopped()
  }

  @IBAction func pause(_ sender: EmptyRoundedButton) {
    pause()
  }

  @IBAction func unpause(_ sender: EmptyRoundedButton) {
    viewModel.unpause()
    togglePauseButton()
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

  fileprivate func togglePauseButton() {
    pauseButton.isHidden = !pauseButton.isHidden
    unpauseButton.isHidden = !unpauseButton.isHidden
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

    pauseButton.setTitle("Pause", for: UIControlState())
  }

  fileprivate func animatePaused() {
    pauseButton.setTitle("Resume", for: UIControlState())
  }

  fileprivate func animateUnpaused() {
    pauseButton.setTitle("Pause", for: UIControlState())
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
    let identifier = (index < viewModel.pomodorosCount.value) ?
      CollectionViewIdentifiers.filledCell : CollectionViewIdentifiers.emptyCell

    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

  // MARK: UICollectionViewDelegate

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {

    let bottomInset: CGFloat = 12
    return UIEdgeInsetsMake(0, 0, bottomInset, 0)
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
    if viewModel.targetPomodorosCount.value % rowsPerSection == 0 {
      return rowsPerSection
    } else {
      return viewModel.targetPomodorosCount.value % rowsPerSection
    }
  }

  fileprivate var numberOfSections: Int {
    return Int(ceil(Double(viewModel.targetPomodorosCount.value) / Double(rowsPerSection)))
  }

  fileprivate var lastSectionIndex: Int {
    if numberOfSections == 0 {
      return 0
    }

    return numberOfSections - 1
  }

}
