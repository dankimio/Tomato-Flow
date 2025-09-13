import AVFoundation
import SnapKit
import SwiftUI
import UIKit

class TimerViewController: UIViewController {

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    return stackView
  }()

  private let timerTextViewModel = TimerTextViewModel()
  private let viewModel = TimerViewModel()
  private lazy var timerHostingController: UIHostingController<TimerTextView> = {
    let hosting = UIHostingController(rootView: TimerTextView(viewModel: timerTextViewModel))
    hosting.view.backgroundColor = .clear
    return hosting
  }()

  private lazy var buttonsContainer: UIStackView = {
    let buttonsStackView = UIStackView()
    buttonsStackView.axis = .horizontal
    buttonsStackView.alignment = .fill
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.spacing = 12
    return buttonsStackView
  }()

  private lazy var startButton: AnimatedButton = {
    let startButton = AnimatedButton(configuration: .primary())
    startButton.setTitle("Start", for: .normal)
    startButton.isHidden = false

    return startButton
  }()

  private lazy var pauseButton: SecondaryButton = {
    let pauseButton = SecondaryButton(configuration: .secondary())
    pauseButton.setTitle("Pause", for: .normal)
    pauseButton.isHidden = true

    return pauseButton
  }()

  private lazy var skipBreakButton: SecondaryButton = {
    let skipButton = SecondaryButton(configuration: .secondary())
    skipButton.setTitle("Skip", for: .normal)
    skipButton.isHidden = true

    return skipButton
  }()

  private lazy var stopButton: AnimatedButton = {
    let stopButton = AnimatedButton(configuration: .primary())
    stopButton.setTitle("Stop", for: .normal)
    stopButton.isHidden = true
    return stopButton
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 32, height: 32)
    let newCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    newCollectionView.register(
      EmptyCell.self,
      forCellWithReuseIdentifier: String(describing: EmptyCell.self)
    )
    newCollectionView.register(
      FilledCell.self,
      forCellWithReuseIdentifier: String(describing: FilledCell.self)
    )
    newCollectionView.dataSource = self
    newCollectionView.backgroundColor = .clear

    return newCollectionView
  }()

  // Scheduler
  private let pomodoro = Pomodoro.sharedInstance

  // Time
  private let soundPlayer = SoundPlayer()

  // Configuration
  private let animationDuration = 0.3
  private let settings = SettingsManager.sharedManager

  // Pomodoros view

  // MARK: - Initialization

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpSubviews()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self, selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    bindViewModel()
    viewModel.refreshOnAppear()
    updateSkipBreakVisibility()
  }

  @objc private func handleDidBecomeActive() {
    viewModel.handleDidBecomeActive()
    reloadData()
    updateSkipBreakVisibility()
  }

  private func setUpSubviews() {
    view.addSubview(stackView)

    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(40)
      make.centerY.equalToSuperview().offset(-64)
      // TODO: do not set fixed height
      make.height.equalTo(352)
    }

    addChild(timerHostingController)
    stackView.addArrangedSubview(timerHostingController.view)
    timerHostingController.didMove(toParent: self)
    stackView.setCustomSpacing(4, after: timerHostingController.view)

    skipBreakButton.addTarget(self, action: #selector(skipBreak), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(skipBreakButton)

    startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(startButton)

    pauseButton.addTarget(self, action: #selector(togglePaused), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(pauseButton)

    stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(stopButton)

    stackView.addArrangedSubview(buttonsContainer)

    buttonsContainer.snp.makeConstraints { make in
      make.height.equalTo(50)
    }

    stackView.setCustomSpacing(48, after: buttonsContainer)

    stackView.addArrangedSubview(collectionView)
  }

  // Timer ticks handled inside ViewModel

  // MARK: - Actions

  @objc private func togglePaused() { viewModel.togglePaused() }

  @objc private func start() {
    viewModel.start()
    generateHapticFeedback()
  }

  @objc private func stop() {
    viewModel.stop()
    updateSkipBreakVisibility()
    generateHapticFeedback()
  }

  @objc private func skipBreak() {
    viewModel.skipBreak()
    updateSkipBreakVisibility()
    generateHapticFeedback()
  }

  // Pause/unpause handled inside ViewModel

  func presentAlertFromNotification(_ notification: UNNotification) {
    let alertController = UIAlertController(
      title: notification.request.content.title,
      message: notification.request.content.body,
      preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in print("OK") }
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  // MARK: - Helpers

  private func reloadData() { collectionView.reloadData() }

  private func updateTimerLabel(seconds: Double) {
    let time = Int(seconds)
    let newString = String(format: "%02d:%02d", time / 60, time % 60)

    withAnimation(.easeInOut(duration: animationDuration)) {
      timerTextViewModel.timeString = newString
    }
  }

  // Time handling moved to ViewModel

  private func resetTimerLabelColor() {
    switch pomodoro.state {
    case .initial:
      timerTextViewModel.textColor = .primary
    case .shortBreak, .longBreak:
      timerTextViewModel.textColor = .green
    }
  }

  // Timer firing handled in ViewModel

  private func playCompletionFeedback() {
    // Haptic feedback for completion
    UINotificationFeedbackGenerator().notificationOccurred(.success)

    // Play custom completion sound when app is in foreground
    soundPlayer.play(resource: "success", withExtension: "wav")
  }

  private func animateStarted() {
    startButton.isHidden = true
    pauseButton.isHidden = false
    stopButton.isHidden = false
    skipBreakButton.isHidden = true
  }

  private func animateStopped() {
    startButton.isHidden = false
    pauseButton.isHidden = true
    stopButton.isHidden = true
    updateSkipBreakVisibility()

    pauseButton.setTitle("Pause", for: .normal)
  }

  private func animatePaused() {
    pauseButton.setTitle("Resume", for: .normal)
  }

  private func animateUnpaused() {
    pauseButton.setTitle("Pause", for: .normal)
  }

  private func generateHapticFeedback() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  private func updateSkipBreakVisibility() {
    skipBreakButton.isHidden = !viewModel.shouldShowSkipBreak
  }

  private func bindViewModel() {
    viewModel.onTimeChanged = { [weak self] seconds in
      self?.updateTimerLabel(seconds: seconds)
    }
    viewModel.onRunningChanged = { [weak self] isRunning in
      if isRunning { self?.animateStarted() } else { self?.animateStopped() }
      self?.updateSkipBreakVisibility()
    }
    viewModel.onPausedChanged = { [weak self] isPaused in
      if isPaused { self?.animatePaused() } else { self?.animateUnpaused() }
    }
    viewModel.onPhaseChanged = { [weak self] _ in
      self?.resetTimerLabelColor()
      self?.updateSkipBreakVisibility()
    }
    viewModel.onCycleCompleted = { [weak self] in
      self?.playCompletionFeedback()
    }
    viewModel.onNeedsReload = { [weak self] in
      self?.reloadData()
    }
  }

}

extension TimerViewController: UICollectionViewDataSource {

  // MARK: UICollectionViewDataSource

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {

    return viewModel.targetPomodorosCount
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let identifier =
      (indexPath.row < viewModel.pomodorosCompletedCount)
      ? String(describing: FilledCell.self) : String(describing: EmptyCell.self)
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

}
