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
  enum PlaybackState { case running, paused, stopped }

  var onTimeChanged: ((Double) -> Void)?
  var onPlaybackStateChanged: ((PlaybackState) -> Void)?
  var onTimerStateChanged: ((TimerState) -> Void)?
  var onCycleCompleted: (() -> Void)?
  var onPomodoroCountersChanged: (() -> Void)?
  var onSkipBreakVisibilityChanged: ((Bool) -> Void)?

  // Derived
  var isSkipBreakVisible: Bool {
    // Show Skip only when on a break, not running, and not paused
    return !running && !scheduler.paused
      && (pomodoro.state == .shortBreak || pomodoro.state == .longBreak)
  }

  var targetPomodorosCount: Int { settings.targetPomodoros }
  var pomodorosCompletedCount: Int { pomodoro.pomodorosCompleted }
  var state: TimerState { pomodoro.state }

  // Lifecycle
  func refreshOnAppear() {
    setCurrentTime()
    emitTime()

    if scheduler.pausedTime != nil {
      running = false
      onPlaybackStateChanged?(.paused)
    } else {
      onPlaybackStateChanged?(.stopped)
    }

    onTimerStateChanged?(pomodoro.state)
    emitSkipVisibility()
  }

  func handleDidBecomeActive() {
    setCurrentTime()
    emitTime()

    if scheduler.pausedTime != nil {
      running = false
      onPlaybackStateChanged?(.paused)
    }

    onTimerStateChanged?(pomodoro.state)
    emitSkipVisibility()
  }

  // Actions
  func start() {
    guard !running else { return }
    scheduler.start()
    running = true
    onPlaybackStateChanged?(.running)
    setCurrentTime()
    emitTime()
    cancelTimer()
    fireTimer()
    emitSkipVisibility()
  }

  func stop() {
    scheduler.stop()
    running = false
    onPlaybackStateChanged?(.stopped)
    cancelTimer()
    resetCurrentTime()
    emitTime()
    onTimerStateChanged?(pomodoro.state)
    emitSkipVisibility()
  }

  func pause() {
    guard running else { return }
    scheduler.pause(currentTime)
    running = false
    cancelTimer()
    onPlaybackStateChanged?(.paused)
    emitSkipVisibility()
  }
  func resume() {
    scheduler.unpause()
    running = true
    cancelTimer()
    fireTimer()
    onPlaybackStateChanged?(.running)
    emitSkipVisibility()
  }

  func skipBreak() {
    guard !running else { return }
    guard pomodoro.state == .shortBreak || pomodoro.state == .longBreak else { return }
    pomodoro.completeBreak()
    resetCurrentTime()
    emitTime()
    onTimerStateChanged?(pomodoro.state)
    emitSkipVisibility()
  }

  // Internals

  private func tick() {
    if currentTime > 0 {
      currentTime = currentTime - 1.0
      emitTime()
      return
    }

    cancelTimer()
    onCycleCompleted?()

    if pomodoro.state == .initial {
      pomodoro.completePomodoro()
      onPomodoroCountersChanged?()
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

  private func cancelTimer() {
    timer?.invalidate()
    timer = nil
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

  private func emitSkipVisibility() {
    onSkipBreakVisibilityChanged?(isSkipBreakVisible)
  }
}
