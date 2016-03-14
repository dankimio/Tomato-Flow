//
//  Scheduler.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-12.
//  Copyright © 2015 Dan K. All rights reserved.
//

import UIKit

protocol SchedulerDelegate: class {
    func schedulerDidPause()
    func schedulerDidUnpause()
    func schedulerDidStart()
    func schedulerDidStop()
}

class Scheduler {

    weak var delegate: SchedulerDelegate?

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = SettingsManager.sharedManager
    private let pomodoro = Pomodoro.sharedInstance

    // Interval for rescheduling timers
    var pausedTime: Double? {
        get {
            return userDefaults.objectForKey("PausedTime") as? Double
        }
        set {
            if let value = newValue where value != 0 {
                userDefaults.setDouble(value, forKey: "PausedTime")
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

    // Returns paused if paused time present
    var paused: Bool {
        return pausedTime != nil
    }

    func start() {
        switch pomodoro.state {
        case .Default: schedulePomodoro()
        case .ShortBreak: scheduleShortBreak()
        case .LongBreak: scheduleLongBreak()
        }

        delegate?.schedulerDidStart()
        print("Scheduler started")
    }

    func pause(interval: NSTimeInterval) {
        pausedTime = interval
        cancelNotification()

        delegate?.schedulerDidPause()
        print("Scheduler paused")
    }

    func unpause() {
        guard let interval = pausedTime else { return }

        switch pomodoro.state {
        case .Default: schedulePomodoro(interval)
        case .ShortBreak: scheduleShortBreak(interval)
        case .LongBreak: scheduleLongBreak(interval)
        }

        pausedTime = nil

        delegate?.schedulerDidUnpause()
        print("Scheduler unpaused")
    }

    func stop() {
        pausedTime = nil
        cancelNotification()

        delegate?.schedulerDidStop()
        print("Scheduler stopped")
    }

    // MARK: - Helpers

    private var firstScheduledNotification: UILocalNotification? {
        return UIApplication.sharedApplication().scheduledLocalNotifications?.first
    }

    private func cancelNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        fireDate = nil
        print("Notification canceled")
    }

    private func schedulePomodoro(interval: NSTimeInterval? = nil) {
        let interval = interval ?? NSTimeInterval(settings.pomodoroLength)
        scheduleNotification(interval,
            title: "Pomodoro finished", body: "Time to take a break!")
        print("Pomodoro scheduled")
    }

    private func scheduleShortBreak(interval: NSTimeInterval? = nil) {
        let interval = interval ?? NSTimeInterval(settings.shortBreakLength)
        scheduleNotification(interval,
            title: "Break finished", body: "Time to get back to work!")
        print("Short break scheduled")
    }

    private func scheduleLongBreak(interval: NSTimeInterval? = nil) {
        let interval = interval ?? NSTimeInterval(settings.longBreakLength)
        scheduleNotification(interval,
            title: "Long break is over", body: "Time to get back to work!")
        print("Long break scheduled")
    }

    private func scheduleNotification(interval: NSTimeInterval, title: String, body: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: interval)
        notification.alertTitle = title
        notification.alertBody = body
        notification.applicationIconBadgeNumber = 1
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

        fireDate = notification.fireDate

        print("Pomodoro notification scheduled for \(notification.fireDate!)")
    }

}
