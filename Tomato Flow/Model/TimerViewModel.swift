import Foundation

final class TimerViewModel {

  // Dependencies
  private let scheduler = Scheduler()
  private let settings = SettingsManager.sharedManager
  private let pomodoro = Pomodoro.sharedInstance

  // State
  private var timer: Timer?
  private var currentTime: Double = 0
  private(set) var running = false

  // Outputs
  var onTimeChanged: ((Double) -> Void)?
  var onRunningChanged: ((Bool) -> Void)?
  var onPausedChanged: ((Bool) -> Void)?
  var onPhaseChanged: ((TimerState) -> Void)?
  var onCycleCompleted: (() -> Void)?
  var onNeedsReload: (() -> Void)?

  // Derived
  var shouldShowSkipBreak: Bool {
    return !running && (pomodoro.state == .shortBreak || pomodoro.state == .longBreak)
  }

  var targetPomodorosCount: Int { settings.targetPomodoros }
  var pomodorosCompletedCount: Int { pomodoro.pomodorosCompleted }
  var state: TimerState { pomodoro.state }

  // Lifecycle
  func refreshOnAppear() {
    setCurrentTime()
    emitTime()

    if scheduler.pausedTime != nil {
      onRunningChanged?(false)
      onPausedChanged?(true)
    } else {
      onRunningChanged?(false)
    }

    onPhaseChanged?(pomodoro.state)
  }

  func handleDidBecomeActive() {
    setCurrentTime()
    emitTime()

    if scheduler.pausedTime != nil {
      onRunningChanged?(false)
      onPausedChanged?(true)
    }

    onPhaseChanged?(pomodoro.state)
  }

  // Actions
  func start() {
    guard !running else { return }
    scheduler.start()
    running = true
    onRunningChanged?(true)
    setCurrentTime()
    emitTime()
    fireTimer()
  }

  func stop() {
    scheduler.stop()
    running = false
    onRunningChanged?(false)
    timer?.invalidate()
    resetCurrentTime()
    emitTime()
    onPhaseChanged?(pomodoro.state)
  }

  func togglePaused() {
    scheduler.paused ? unpause() : pause()
  }

  func skipBreak() {
    guard !running else { return }
    guard pomodoro.state == .shortBreak || pomodoro.state == .longBreak else { return }
    pomodoro.completeBreak()
    resetCurrentTime()
    emitTime()
    onPhaseChanged?(pomodoro.state)
  }

  // Internals
  private func pause() {
    guard running else { return }
    scheduler.pause(currentTime)
    running = false
    timer?.invalidate()
    onPausedChanged?(true)
    onRunningChanged?(false)
  }

  private func unpause() {
    scheduler.unpause()
    running = true
    fireTimer()
    onPausedChanged?(false)
    onRunningChanged?(true)
  }

  private func tick() {
    if currentTime > 0 {
      currentTime = currentTime - 1.0
      emitTime()
      return
    }

    onCycleCompleted?()

    if pomodoro.state == .initial {
      pomodoro.completePomodoro()
      onNeedsReload?()
    } else {
      pomodoro.completeBreak()
    }

    stop()
  }

  private func fireTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
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
  }

  private func emitTime() {
    onTimeChanged?(currentTime)
  }
}
