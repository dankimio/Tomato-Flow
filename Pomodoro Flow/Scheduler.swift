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
    
    static let sharedInstance = Scheduler()

    private init() { }

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = Settings.sharedInstance
    private let pomodoro = Pomodoro.sharedInstance

    // MARK: - Helpers

    private var firstScheduledNotification: UILocalNotification? {
        return UIApplication.sharedApplication().scheduledLocalNotifications?.first
    }

    func suspend() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        pomodoro.fireDate = nil
        
        print("Notification canceled")
    }
    
    func schedulePomodoro(interval: Int? = nil) {
        let interval = interval ?? settings.pomodoroLength
        scheduleNotification(NSTimeInterval(interval),
            title: "Pomodoro finished", body: "Time to take a break!")
        print("Pomodoro scheduled")
    }

    func scheduleShortBreak(interval: Int? = nil) {
        let interval = interval ?? settings.shortBreakLength
        scheduleNotification(NSTimeInterval(interval),
            title: "Break finished", body: "Time to get back to work!")
        print("Short break scheduled")
    }

    func scheduleLongBreak(interval: Int? = nil) {
        let interval = interval ?? settings.longBreakLength
        scheduleNotification(NSTimeInterval(interval),
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

        pomodoro.fireDate = notification.fireDate

        print("Pomodoro notification scheduled for \(notification.fireDate!)")
    }

}
