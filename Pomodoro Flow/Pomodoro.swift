import Foundation

// Pomodoro is a singleton object that handles pomodoros and breaks logic
class Pomodoro {

  static let sharedInstance = Pomodoro()

  let userDefaults = UserDefaults.standard
  let settings = SettingsManager.sharedManager

  var state: TimerState = .initial

  fileprivate init() {}

  var pomodorosCompleted: Int {
    get {
      return userDefaults.integer(forKey: currentDateKey)
    }
    set {
      userDefaults.set(newValue, forKey: currentDateKey)
    }
  }

  func completePomodoro() {
    pomodorosCompleted += 1
    state = (pomodorosCompleted % 4 == 0 ? .longBreak : .shortBreak)
  }

  func completeBreak() {
    state = .initial
  }

  fileprivate var currentDateKey: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
  }

}
