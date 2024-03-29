import Foundation

// Singleton object to retrieve and retain app settings
class SettingsManager {

  static let sharedManager = SettingsManager()
  private init() {}

  private let userDefaults = UserDefaults.standard
  private let notificationCenter = NotificationCenter.default

  private struct Settings {
    static let pomodoroLength = "Settings.PomodoroLength"
    static let shortBreakLength = "Settings.ShortBreakLength"
    static let longBreakLength = "Settings.LongBreakLength"
    static let targetPomodoros = "Settings.TargetPomodoros"
  }

  // MARK: - General settings

  var pomodoroLength: Int {
    get { return userDefaults.object(forKey: Settings.pomodoroLength) as? Int ?? 25 * 60 }
    set { userDefaults.set(newValue, forKey: Settings.pomodoroLength) }
  }

  var shortBreakLength: Int {
    get { return userDefaults.object(forKey: Settings.shortBreakLength) as? Int ?? 5 * 60 }
    set { userDefaults.set(newValue, forKey: Settings.shortBreakLength) }
  }

  var longBreakLength: Int {
    get { return userDefaults.object(forKey: Settings.longBreakLength) as? Int ?? 20 * 60 }
    set { userDefaults.set(newValue, forKey: Settings.longBreakLength) }
  }

  var targetPomodoros: Int {
    get { return userDefaults.object(forKey: Settings.targetPomodoros) as? Int ?? 5 }
    set {
      userDefaults.set(newValue, forKey: Settings.targetPomodoros)
      notificationCenter.post(name: Notification.Name(rawValue: "targetPomodorosUpdated"), object: self)
    }
  }

}
