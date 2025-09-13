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
  private let scheduler = Scheduler()
  private let pomodoro = Pomodoro.sharedInstance

  // Time
  private var timer: Timer?
  private var currentTime: Double = 0
  private var running = false

  // Configuration
  private let animationDuration = 0.3
  private let settings = SettingsManager.sharedManager

  // Pomodoros view

  // Audio
  private var completionPlayer: AVAudioPlayer?

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

    // Initialize UI state
    resetCurrentTime()
    updateTimerLabel()
    updateSkipBreakVisibility()
  }

  @objc private func handleDidBecomeActive() {
    setCurrentTime()
    updateTimerLabel()

    if scheduler.pausedTime != nil {
      animateStarted()
      animatePaused()
    }

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

  @objc private func tick() {
    if currentTime > 0 {
      currentTime = currentTime - 1.0
      updateTimerLabel()
      return
    }

    playCompletionFeedback()

    if pomodoro.state == .initial {
      pomodoro.completePomodoro()
      reloadData()
    } else {
      pomodoro.completeBreak()
    }

    stop()
  }

  // MARK: - Actions

  @objc private func togglePaused() {
    scheduler.paused ? unpause() : pause()
  }

  @objc private func start() {
    guard !running else { return }

    scheduler.start()
    running = true
    animateStarted()
    fireTimer()
    generateHapticFeedback()
  }

  @objc private func stop() {
    scheduler.stop()
    running = false
    animateStopped()
    timer?.invalidate()
    resetCurrentTime()
    updateTimerLabel()
    updateSkipBreakVisibility()
    generateHapticFeedback()
  }

  @objc private func skipBreak() {
    guard !running else { return }
    guard pomodoro.state == .shortBreak || pomodoro.state == .longBreak else { return }

    pomodoro.completeBreak()
    resetCurrentTime()
    updateTimerLabel()
    updateSkipBreakVisibility()
    generateHapticFeedback()
  }

  private func pause() {
    guard running else { return }

    scheduler.pause(currentTime)
    running = false
    timer?.invalidate()
    animatePaused()
    generateHapticFeedback()
  }

  private func unpause() {
    scheduler.unpause()
    running = true
    fireTimer()
    animateUnpaused()
    generateHapticFeedback()
  }

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

  private func reloadData() {
    collectionView.reloadData()
  }

  private func updateTimerLabel() {
    let time = Int(currentTime)
    let newString = String(format: "%02d:%02d", time / 60, time % 60)

    withAnimation(.easeInOut(duration: animationDuration)) {
      timerTextViewModel.timeString = newString
    }
  }

  private func setCurrentTime() {
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

  private func resetCurrentTime() {
    switch pomodoro.state {
    case .initial: currentTime = Double(settings.pomodoroLength)
    case .shortBreak: currentTime = Double(settings.shortBreakLength)
    case .longBreak: currentTime = Double(settings.longBreakLength)
    }
    resetTimerLabelColor()
  }

  private func resetTimerLabelColor() {
    switch pomodoro.state {
    case .initial:
      timerTextViewModel.textColor = .primary
    case .shortBreak, .longBreak:
      timerTextViewModel.textColor = .green
    }
  }

  private func fireTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(tick),
      userInfo: nil,
      repeats: true
    )
  }

  private func playCompletionFeedback() {
    // Haptic feedback for completion
    UINotificationFeedbackGenerator().notificationOccurred(.success)

    // Play custom completion sound when app is in foreground
    guard let url = Bundle.main.url(forResource: "success", withExtension: "wav") else {
      return
    }

    do {
      completionPlayer = try AVAudioPlayer(contentsOf: url)
      completionPlayer?.prepareToPlay()
      completionPlayer?.play()
    } catch {
      print("Failed to play completion sound: \(error)")
    }
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
    let onBreak = (pomodoro.state == .shortBreak || pomodoro.state == .longBreak)
    skipBreakButton.isHidden = running || !onBreak
  }

}

extension TimerViewController: UICollectionViewDataSource {

  // MARK: UICollectionViewDataSource

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {

    return settings.targetPomodoros
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let identifier =
      (indexPath.row < pomodoro.pomodorosCompleted)
      ? String(describing: FilledCell.self) : String(describing: EmptyCell.self)
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

}
