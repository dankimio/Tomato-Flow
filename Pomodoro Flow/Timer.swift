//
//  Timer.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-12.
//  Copyright © 2015 Dan K. All rights reserved.
//

import UIKit

protocol TimerDelegate: class {
    func timerUpdated()
    func timerDidPause()
    func timerDidUnpause()
    func timerDidStart()
    func timerDidStop()
}

class Timer {

    var paused = false
    var stopped = true

    var currentTime: Double {
        didSet {
            delegate.timerUpdated()
        }
    }
    
    private var delegate: TimerDelegate!
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = SettingsManager.sharedManager
    private var timer: NSTimer?

    private var pausedTime: Double {
        get { return userDefaults.doubleForKey("pausedTime") }
        set {
            if newValue == 0 {
                userDefaults.removeObjectForKey("pausedTime")
            } else {
                userDefaults.setDouble(newValue, forKey: "pausedTime")
            }
        }
    }
    
    init(delegate: TimerDelegate) {
        self.delegate = delegate

        if let notification = UIApplication.sharedApplication().scheduledLocalNotifications?.first,
            fireDate = notification.fireDate {
                currentTime = fireDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970
                start()
        } else if let pausedTime = userDefaults.objectForKey("pausedTime") as? Double {
            currentTime = pausedTime
            paused = true
            stopped = false
        } else {
            currentTime = settings.pomodoroLengthInterval
        }
    }
    
    deinit {
        invalidateTimer()
        
        print("Timer deinitialized")
    }
    
    func start() {
        fireTimer()
        schedulePomodoroNotification(settings.pomodoroLengthInterval)
        stopped = false
        
        delegate.timerDidStart()
        
        print("Timer started")
    }
    
    func togglePause() {
        if paused {
            unpause()
        } else {
            pause()
        }
    }
    
    private func pause() {
        paused = true
        pausedTime = currentTime

        invalidateTimer()
        cancelNotification()
        
        delegate.timerDidPause()
        print("Timer paused")
    }
    
    private func unpause() {
        paused = false

        fireTimer()
        schedulePomodoroNotification(pausedTime)
        
        delegate.timerDidUnpause()
        print("Timer unpaused")
    }
    
    func stop() {
        paused = false
        pausedTime = 0

        invalidateTimer()
        cancelNotification()
        currentTime = settings.pomodoroLengthInterval
        stopped = true
        
        delegate.timerDidStop()
        
        print("Timer stopped")
    }
    
    func reloadSettings() {
        if stopped {
            currentTime = settings.pomodoroLengthInterval
        }
    }
    
    private func fireTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self, selector: "decrementCurrentTime", userInfo: nil, repeats: true)
        
        print("Timer fired")
    }
    
    @objc func decrementCurrentTime() {
        currentTime--
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        
        print("Timer invalidated")
    }
    
    private func cancelNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
    private func schedulePomodoroNotification(interval: NSTimeInterval) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: interval)
        notification.alertTitle = "Pomodoro Finished!"
        notification.alertBody = "Time to take a break"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        print("Pomodoro notification scheduled")
    }
    
    private func scheduleShortBreak(interval: NSTimeInterval) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: interval)
        notification.alertTitle = "Break Finished!"
        notification.alertBody = "Time to get back to work"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        print("Short break scheduled")
    }
}