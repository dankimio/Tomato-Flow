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

    var scheduled = true

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = SettingsManager.sharedManager

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
    
    // Returns paused if paused time present
    var paused: Bool {
        return pausedTime != nil
    }
    
    func start() {
        schedulePomodoro()
        
        scheduled = false
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
    
        scheduleNotification(interval, title: "Pomodoro finished!", body: "Time to take a break.")
        pausedTime = nil
        
        delegate?.schedulerDidUnpause()
        print("Scheduler unpaused")
    }
    
    func stop() {
        scheduled = false
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
        print("Notification canceled")
    }
    
    private func schedulePomodoro() {
        let interval = NSTimeInterval(settings.pomodoroLength)
        scheduleNotification(interval, title: "Pomodoro finished!", body: "Time to take a break.")
        print("Pomodoro scheduled")
    }
    
    private func scheduleShortBreak() {
        let interval = NSTimeInterval(settings.shortBreakLength)
        scheduleNotification(interval, title: "Break finished!", body: "Time to get back to work")
        print("Short break scheduled")
    }
    
    private func scheduleLongBreak() {
        let interval = NSTimeInterval(settings.longBreakLength)
        scheduleNotification(interval, title: "Long break is over!", body: "Time to get back to work")
        print("Long break scheduled")
    }
    
    private func scheduleNotification(interval: NSTimeInterval, title: String, body: String) {
        let notification = UILocalNotification()
        // FIXME: Set fire date to parameter value
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        notification.alertTitle = title
        notification.alertBody = body
        notification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        print("Pomodoro notification scheduled for \(notification.fireDate!)")
    }

}
