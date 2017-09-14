//
//  SettingsManager.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import Foundation

// Singleton object to retrieve and retain app settings
class SettingsManager {

    static let sharedManager = SettingsManager()
    fileprivate init() {}

    fileprivate let userDefaults = UserDefaults.standard
    fileprivate let notificationCenter = NotificationCenter.default

    fileprivate struct Settings {
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
