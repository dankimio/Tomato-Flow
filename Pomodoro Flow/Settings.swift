//
//  SettingsManager.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import Foundation

// Singleton object to retrieve and retain app settings
class Settings {

    static let sharedInstance = Settings()
    private init() {}

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let notificationCenter = NSNotificationCenter.defaultCenter()

    private struct Options {
        static let pomodoroLength = "Settings.PomodoroLength"
        static let shortBreakLength = "Settings.ShortBreakLength"
        static let longBreakLength = "Settings.LongBreakLength"
        static let targetPomodoros = "Settings.TargetPomodoros"
    }

    // MARK: - General settings

    var pomodoroLength: Int {
        get { return userDefaults.objectForKey(Options.pomodoroLength) as? Int ?? 25 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Options.pomodoroLength) }
    }

    var shortBreakLength: Int {
        get { return userDefaults.objectForKey(Options.shortBreakLength) as? Int ?? 5 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Options.shortBreakLength) }
    }

    var longBreakLength: Int {
        get { return userDefaults.objectForKey(Options.longBreakLength) as? Int ?? 20 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Options.longBreakLength) }
    }

    var targetPomodoros: Int {
        get { return userDefaults.objectForKey(Options.targetPomodoros) as? Int ?? 5 }
        set {
            userDefaults.setInteger(newValue, forKey: Options.targetPomodoros)
            notificationCenter.postNotificationName("targetPomodorosUpdated", object: self)
        }
    }

}
