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
    let settings = Settings.sharedInstance

    private init() {}

    var pomodorosCount: Int {
        get {
            return userDefaults.integerForKey(currentDateKey)
        }
        set {
            userDefaults.setInteger(newValue, forKey: currentDateKey)
        }
    }
    
    // Interval for rescheduling timers
    var pausedTime: Int? {
        get {
            return userDefaults.objectForKey("PausedTime") as? Int
        }
        set {
            if let value = newValue where value != 0 {
                userDefaults.setInteger(value, forKey: "PausedTime")
            } else {
                userDefaults.removeObjectForKey("PausedTime")
            }
        }
    }
    
    // Date representing fire date of scheduled notification
    var fireDate: NSDate? {
        get {
            return userDefaults.objectForKey("FireDate") as? NSDate
        }
        set {
            if let value = newValue {
                userDefaults.setObject(value, forKey: "FireDate")
            } else {
                userDefaults.removeObjectForKey("FireDate")
            }
        }
    }
    
    // Return paused if paused time present
    var paused: Bool {
        return pausedTime != nil
    }

    private var currentDateKey: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(NSDate())
    }

}
