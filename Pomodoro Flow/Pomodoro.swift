//
//  Pomodoro.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2016-03-13.
//  Copyright © 2016 Dan K. All rights reserved.
//

import Foundation

// Pomodoro is a singleton object that handles pomodoros and breaks logic
class Pomodoro {
    
    static let sharedInstance = Pomodoro()

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let settings = SettingsManager.sharedManager
    
    var state: State = .Default
    
    private init() {}
    
    var pomodorosCompleted: Int {
        get {
            return userDefaults.integerForKey(currentDateKey)
        }
        set {
            userDefaults.setInteger(newValue, forKey: currentDateKey)
        }
    }
    
    func completePomodoro() {
        pomodorosCompleted += 1
        state = (pomodorosCompleted % 4 == 0 ? .LongBreak : .ShortBreak)
    }
    
    func completeBreak() {
        state = .Default
    }
    
    private var currentDateKey: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(NSDate())
    }
    
}