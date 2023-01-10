import UIKit
import SnapKit

class TimerViewController: UIViewController {

  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!
  @IBOutlet weak var buttonContainer: UIView!

  @IBOutlet weak var timerLabel: UILabel! {
    didSet {
      timerLabel.font = UIFont.monospacedDigitSystemFont(
        ofSize: 124.0,
        weight: UIFont.Weight.light
      )
    }
  }

  @IBOutlet weak var collectionView: UICollectionView!
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    return stackView
  }()
  
  private lazy var newTimerLabel: UILabel = {
    let newTimerLabel = UILabel()
    newTimerLabel.text = "25:00"
    newTimerLabel.font = UIFont.monospacedDigitSystemFont(
      ofSize: 96, weight: .medium
    )
    return newTimerLabel
  }()
  
  private lazy var newCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 32, height: 32)
    let newCollectionView =  UICollectionView(frame: .zero, collectionViewLayout: layout)
    newCollectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
    newCollectionView.dataSource = self

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
    
    view.addSubview(stackView)
    
    stackView.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(50)
      make.leading.equalToSuperview().offset(40)
      make.trailing.equalToSuperview().offset(-40)
      make.bottom.equalToSuperview().offset(-100)
    }
    
    stackView.addArrangedSubview(newTimerLabel)
    stackView.addArrangedSubview(newCollectionView)

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

  @objc func secondPassed() {
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
    case .initial: timerLabel.textColor = UIColor.accentColor
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

extension TimerViewController: UICollectionViewDataSource {

  // MARK: UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {

    return 10
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath)
    return cell
  }

}
