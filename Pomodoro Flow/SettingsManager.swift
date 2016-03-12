//
//  SettingsManager.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import Foundation

class SettingsManager {
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    private struct Settings {
        static let pomodoroLength = "Settings.PomodoroLength"
        static let shortBreakLength = "Settings.ShortBreakLength"
        static let longBreakLength = "Settings.LongBreakLength"
        static let targetPomodoros = "Settings.TargetPomodoros"
        
        static let tickingSound = "Settings.TickingSound"
        static let startBreaks = "Settings.StartBreaks"
        static let startPomodoros = "Settings.StartPomodoros"
    }
    
    static let sharedManager = SettingsManager()
    
    private init() {}
    
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
        get { return userDefaults.objectForKey(Settings.targetPomodoros) as? Int ?? 5 * 60 }
        set {
            userDefaults.setInteger(newValue, forKey: Settings.targetPomodoros)
            notificationCenter.postNotificationName("targetPomodorosUpdated", object: self)
        }
    }
    
    // MARK: - Notification settings
    
    var tickingSound: Bool {
        get { return userDefaults.boolForKey(Settings.tickingSound) }
        set { userDefaults.setBool(newValue, forKey: Settings.tickingSound) }
    }
    
    var startBreaks: Bool {
        get { return userDefaults.boolForKey(Settings.startBreaks) }
        set { userDefaults.setBool(newValue, forKey: Settings.startBreaks) }
    }
    
    var startPomodoros: Bool {
        get { return userDefaults.boolForKey(Settings.startPomodoros) }
        set { userDefaults.setBool(newValue, forKey: Settings.startPomodoros) }
    }

}
