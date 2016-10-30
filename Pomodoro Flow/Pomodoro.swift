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

  let userDefaults = UserDefaults.standard
  let settings = Settings.sharedInstance

  fileprivate init() {}

  var pomodorosCount: Int {
    get {
      return userDefaults.integer(forKey: currentDateKey)
    }
    set {
      userDefaults.set(newValue, forKey: currentDateKey)
    }
  }

  // Interval for rescheduling timers
  var pausedTime: Int? {
    get {
      return userDefaults.object(forKey: "PausedTime") as? Int
    }
    set {
      if let value = newValue, value != 0 {
        userDefaults.set(value, forKey: "PausedTime")
      } else {
        userDefaults.removeObject(forKey: "PausedTime")
      }
    }
  }

  // Date representing fire date of scheduled notification
  var fireDate: Date? {
    get {
      return userDefaults.object(forKey: "FireDate") as? Date
    }
    set {
      if let value = newValue {
        userDefaults.set(value, forKey: "FireDate")
      } else {
        userDefaults.removeObject(forKey: "FireDate")
      }
    }
  }

  // Return paused if paused time present
  var paused: Bool {
    return pausedTime != nil
  }

  fileprivate var currentDateKey: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: Date())
  }

}
