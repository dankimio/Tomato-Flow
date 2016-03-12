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
    
    var paused: Bool {
        return pausedTime != nil
    }
    
    private var firstScheduledNotification: UILocalNotification? {
        return UIApplication.sharedApplication().scheduledLocalNotifications?.first
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

    private func cancelNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("Notification canceled")
    }
    
    private func schedulePomodoro() {
        let interval = NSTimeInterval(settings.pomodoroLength)
        scheduleNotification(interval, title: "Pomodoro finished!", body: "Time to take a break.")
        print("Pomodoro scheduled")
    }
    
    private func scheduleShortBreak(interval: NSTimeInterval) {
        let interval = NSTimeInterval(settings.shortBreakLength)
        scheduleNotification(interval, title: "Break finished!", body: "Time to get back to work")
        print("Short break scheduled")
    }
    
    // TODO: Implement
    private func scheduleLongBreak() {
        
    }
    
    // TODO: Implement
    private func scheduleBreak() {
        
    }
    
    // TODO: Implement
    private func scheduleNotification(interval: NSTimeInterval, title: String, body: String) {
        let notification = UILocalNotification()
        // FIXME: Fix later
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        notification.alertTitle = title
        notification.alertBody = body
        notification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        print("Pomodoro notification scheduled for \(notification.fireDate)")
    }
}