import UIKit
import SnapKit

class TimerViewController: UIViewController {

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    return stackView
  }()

  private lazy var timerLabel: UILabel = {
    let timerLabel = UILabel()
    timerLabel.text = "25:00"
    timerLabel.textAlignment = .center
    timerLabel.font = UIFont.monospacedDigitSystemFont(
      ofSize: 128, weight: .medium
    )
    timerLabel.adjustsFontSizeToFitWidth = true
    return timerLabel
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

  private lazy var stopButton: AnimatedButton = {
    let stopButton = AnimatedButton(configuration: .primary())
    stopButton.setTitle("Stop", for: .normal)
    stopButton.isHidden = true
    return stopButton
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 32, height: 32)
    let newCollectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
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
  private let scheduler: Scheduler
  private let pomodoro = Pomodoro.sharedInstance

  // Time
  private var timer: Timer?
  private var currentTime: Double!
  private var running = false

  // Configuration
  private let animationDuration = 0.3
  private let settings = SettingsManager.sharedManager

  // Pomodoros view
  private var pomodorosCompleted: Int!
  private var targetPomodoros: Int

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

    setUpSubviews()

    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    willEnterForeground()
  }

  @objc func willEnterForeground() {
    print("willEnterForeground")

    setCurrentTime()
    updateTimerLabel()

    if scheduler.pausedTime != nil {
      animateStarted()
      animatePaused()
    }

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

    stackView.addArrangedSubview(timerLabel)

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

  @objc func tick() {
    if currentTime > 0 {
      currentTime = currentTime - 1.0
      updateTimerLabel()
      return
    }

    print("State: \(pomodoro.state), done: \(pomodoro.pomodorosCompleted)")

    if pomodoro.state == .initial {
      pomodoro.completePomodoro()
      reloadData()
    } else {
      pomodoro.completeBreak()
    }

    stop()

    print("State: \(pomodoro.state), done: \(pomodoro.pomodorosCompleted)")
  }

  // MARK: - Actions

  @objc func togglePaused() {
    scheduler.paused ? unpause() :pause()
  }

  @objc func start() {
    guard !running else { return }

    scheduler.start()
    running = true
    animateStarted()
    fireTimer()
    generateHapticFeedback()
  }

  @objc func stop() {
    scheduler.stop()
    running = false
    animateStopped()
    timer?.invalidate()
    resetCurrentTime()
    updateTimerLabel()
    generateHapticFeedback()
  }

  func pause() {
    guard running else { return }

    scheduler.pause(currentTime)
    running = false
    timer?.invalidate()
    animatePaused()
    generateHapticFeedback()
  }

  func unpause() {
    scheduler.unpause()
    running = true
    fireTimer()
    animateUnpaused()
    generateHapticFeedback()
  }

  func presentAlertFromNotification(_ notification: UNNotification) {
    let alertController = UIAlertController(title: notification.request.content.title,
                                            message: notification.request.content.body,
                                            preferredStyle: .alert)

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in print("OK") }
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  // MARK: - Helpers

  private func reloadData() {
    targetPomodoros = settings.targetPomodoros
    pomodorosCompleted = pomodoro.pomodorosCompleted
    collectionView.reloadData()
  }

  private func updateTimerLabel() {
    let time = Int(currentTime)
    timerLabel.text = String(format: "%02d:%02d", time / 60, time % 60)
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
    case .initial: timerLabel.textColor = UIColor.label
    case .shortBreak, .longBreak: timerLabel.textColor = UIColor.systemGreen
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

  private func refreshPomodoros() {
    targetPomodoros = settings.targetPomodoros
  }

  private func animateStarted() {
    startButton.isHidden = true
    pauseButton.isHidden = false
    stopButton.isHidden = false
  }

  private func animateStopped() {
    startButton.isHidden = false
    pauseButton.isHidden = true
    stopButton.isHidden = true

    pauseButton.setTitle("Pause", for: UIControl.State())
  }

  private func animatePaused() {
    pauseButton.setTitle("Resume", for: UIControl.State())
  }

  private func animateUnpaused() {
    pauseButton.setTitle("Pause", for: UIControl.State())
  }

  private func generateHapticFeedback() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

}

extension TimerViewController: UICollectionViewDataSource {

  // MARK: UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {

    return targetPomodoros
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let identifier = (indexPath.row < pomodorosCompleted) ?
      String(describing: FilledCell.self) : String(describing: EmptyCell.self)
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

}
