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
    let settings = SettingsManager.sharedManager

    var state: State = .default

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
        state = .default
    }

    fileprivate var currentDateKey: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }

}
