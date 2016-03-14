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
    private init() {}

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    private struct Settings {
        static let pomodoroLength = "Settings.PomodoroLength"
        static let shortBreakLength = "Settings.ShortBreakLength"
        static let longBreakLength = "Settings.LongBreakLength"
        static let targetPomodoros = "Settings.TargetPomodoros"
    }
    
    // MARK: - General settings
    
    var pomodoroLength: Int {
        get { return userDefaults.objectForKey(Settings.pomodoroLength) as? Int ?? 25 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Settings.pomodoroLength) }
    }
    
    var shortBreakLength: Int {
        get { return userDefaults.objectForKey(Settings.shortBreakLength) as? Int ?? 5 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Settings.shortBreakLength) }
    }
    
    var longBreakLength: Int {
        get { return userDefaults.objectForKey(Settings.longBreakLength) as? Int ?? 20 * 60 }
        set { userDefaults.setInteger(newValue, forKey: Settings.longBreakLength) }
    }
    
    var targetPomodoros: Int {
        get { return userDefaults.objectForKey(Settings.targetPomodoros) as? Int ?? 5 }
        set {
            userDefaults.setInteger(newValue, forKey: Settings.targetPomodoros)
            notificationCenter.postNotificationName("targetPomodorosUpdated", object: self)
        }
    }

}
