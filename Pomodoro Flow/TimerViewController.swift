import UIKit
import SnapKit

class TimerViewController: UIViewController {

  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    return stackView
  }()

  // TODO: center
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

  private lazy var startButton: UIButton = {
    // TODO: get rid of repetition
    var buttonConfiguration = UIButton.Configuration.filled()
    buttonConfiguration.baseBackgroundColor = Colors.primary
    let startButton = UIButton(configuration: buttonConfiguration)
    startButton.setTitle("Start", for: .normal)
    startButton.isHidden = false
    return startButton
  }()

  private lazy var pauseButton: UIButton = {
    var buttonConfiguration = UIButton.Configuration.filled()
    buttonConfiguration.baseBackgroundColor = UIColor.clear
    buttonConfiguration.baseForegroundColor = Colors.primary
    let pauseButton = UIButton(configuration: buttonConfiguration)
    pauseButton.setTitle("Pause", for: .normal)
    pauseButton.setTitleColor(.red, for: .normal)
    pauseButton.layer.cornerRadius = 6
    pauseButton.layer.borderWidth = 2
    pauseButton.layer.borderColor = Colors.primary.cgColor
    pauseButton.isHidden = true
    return pauseButton
  }()

  private lazy var stopButton: UIButton = {
    // TODO: get rid of repetition
    var buttonConfiguration = UIButton.Configuration.filled()
    buttonConfiguration.baseBackgroundColor = Colors.primary
    let stopButton = UIButton(configuration: buttonConfiguration)
    stopButton.setTitle("Stop", for: .normal)
    stopButton.isHidden = true
    return stopButton
  }()

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 32, height: 32)
    let newCollectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
    newCollectionView.register(EmptyCell.self, forCellWithReuseIdentifier: "EmptyCell")
    newCollectionView.register(FilledCell.self, forCellWithReuseIdentifier: "FilledCell")
    newCollectionView.dataSource = self
    newCollectionView.backgroundColor = .clear

    return newCollectionView
  }()

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
      make.leading.equalToSuperview().offset(40)
      make.trailing.equalToSuperview().offset(-40)
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
  }

  @objc func stop() {
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

    let okAction = UIAlertAction(title: "OK", style: .default) { _ in print("OK") }
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
    case .initial: currentTime = Double(settings.pomodoroLength)
    case .shortBreak: currentTime = Double(settings.shortBreakLength)
    case .longBreak: currentTime = Double(settings.longBreakLength)
    }
    resetTimerLabelColor()
  }

  fileprivate func resetTimerLabelColor() {
    switch pomodoro.state {
    case .initial: timerLabel.textColor = UIColor.label
    case .shortBreak, .longBreak: timerLabel.textColor = UIColor.systemGreen
    }
  }

  fileprivate func fireTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(tick),
      userInfo: nil,
      repeats: true
    )
  }

  fileprivate func refreshPomodoros() {
    targetPomodoros = settings.targetPomodoros
  }

  fileprivate func animateStarted() {
    startButton.isHidden = true
    pauseButton.isHidden = false
    stopButton.isHidden = false
  }

  fileprivate func animateStopped() {
    startButton.isHidden = false
    pauseButton.isHidden = true
    stopButton.isHidden = true

    pauseButton.setTitle("Pause", for: UIControl.State())
  }

  fileprivate func animatePaused() {
    pauseButton.setTitle("Resume", for: UIControl.State())
  }

  fileprivate func animateUnpaused() {
    pauseButton.setTitle("Pause", for: UIControl.State())
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
    let identifier = (indexPath.row < pomodorosCompleted) ? "FilledCell" : "EmptyCell"
    return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

}
