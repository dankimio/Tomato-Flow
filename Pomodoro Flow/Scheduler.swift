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

  fileprivate init() { }

  fileprivate let userDefaults = UserDefaults.standard
  fileprivate let settings = Settings.sharedInstance
  fileprivate let pomodoro = Pomodoro.sharedInstance

  // MARK: - Helpers

  fileprivate var firstScheduledNotification: UILocalNotification? {
    return UIApplication.shared.scheduledLocalNotifications?.first
  }

  func suspend() {
    UIApplication.shared.cancelAllLocalNotifications()
    pomodoro.fireDate = nil

    print("Notification canceled")
  }

  func schedulePomodoro(_ interval: Int? = nil) {
    let interval = interval ?? settings.pomodoroLength

    scheduleNotification(TimeInterval(interval),
                         title: "Pomodoro finished",
                         body: "Time to take a break!")

    print("Pomodoro scheduled")
  }

  func scheduleShortBreak(_ interval: Int? = nil) {
    let interval = interval ?? settings.shortBreakLength

    scheduleNotification(TimeInterval(interval),
                         title: "Break finished",
                         body: "Time to get back to work!")

    print("Short break scheduled")
  }

  func scheduleLongBreak(_ interval: Int? = nil) {
    let interval = interval ?? settings.longBreakLength

    scheduleNotification(TimeInterval(interval),
                         title: "Long break is over",
                         body: "Time to get back to work!")

    print("Long break scheduled")
  }

  fileprivate func scheduleNotification(_ interval: TimeInterval, title: String, body: String) {
    let notification = UILocalNotification()

    notification.fireDate = Date(timeIntervalSinceNow: interval)
    notification.alertTitle = title
    notification.alertBody = body
    notification.applicationIconBadgeNumber = 1
    notification.soundName = UILocalNotificationDefaultSoundName

    UIApplication.shared.scheduleLocalNotification(notification)

    pomodoro.fireDate = notification.fireDate

    print("Pomodoro notification scheduled for \(notification.fireDate!)")
  }

}
