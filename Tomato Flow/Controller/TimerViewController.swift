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

  private lazy var resumeButton: SecondaryButton = {
    let resumeButton = SecondaryButton(configuration: .secondary())
    resumeButton.setTitle("Resume", for: .normal)
    resumeButton.isHidden = true

    return resumeButton
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

    view.backgroundColor = .systemBackground
    setUpSubviews()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self, selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification, object: nil)

    bindViewModel()
    viewModel.refreshOnAppear()
  }

  @objc private func handleDidBecomeActive() {
    viewModel.handleDidBecomeActive()
    reloadData()
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

    pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(pauseButton)

    resumeButton.addTarget(self, action: #selector(resume), for: .touchUpInside)
    buttonsContainer.addArrangedSubview(resumeButton)

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

  @objc private func pause() {
    viewModel.pause()
    generateHapticFeedback()
  }
  @objc private func resume() {
    viewModel.resume()
    generateHapticFeedback()
  }

  @objc private func start() {
    viewModel.start()
    generateHapticFeedback()
  }

  @objc private func stop() {
    viewModel.stop()
    generateHapticFeedback()
  }

  @objc private func skipBreak() {
    viewModel.skipBreak()
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
    resumeButton.isHidden = true
    stopButton.isHidden = false
    skipBreakButton.isHidden = true
  }

  private func animateStopped() {
    startButton.isHidden = false
    pauseButton.isHidden = true
    resumeButton.isHidden = true
    stopButton.isHidden = true

  }

  private func animatePaused() {
    pauseButton.isHidden = true
    resumeButton.isHidden = false
  }

  private func animateUnpaused() {
    pauseButton.isHidden = false
    resumeButton.isHidden = true
  }

  private func generateHapticFeedback() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  private func bindViewModel() {
    viewModel.onTimeChanged = { [weak self] seconds in
      self?.updateTimerLabel(seconds: seconds)
    }
    viewModel.onPlaybackStateChanged = { [weak self] state in
      switch state {
      case .running:
        self?.animateStarted()
        self?.animateUnpaused()
      case .paused:
        self?.animateStarted()
        self?.animatePaused()
      case .stopped:
        self?.animateStopped()
      }
    }
    viewModel.onTimerStateChanged = { [weak self] _ in
      self?.resetTimerLabelColor()
    }
    viewModel.onCycleCompleted = { [weak self] in
      self?.playCompletionFeedback()
    }
    viewModel.onPomodoroCountersChanged = { [weak self] in
      self?.reloadData()
    }
    viewModel.onSkipBreakVisibilityChanged = { [weak self] isVisible in
      self?.skipBreakButton.isHidden = !isVisible
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
