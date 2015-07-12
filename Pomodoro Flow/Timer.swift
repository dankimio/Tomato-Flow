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
    private static var sharedInstance: Timer?
    
    class func sharedTimer(delegate: TimerDelegate) -> Timer {
        if sharedInstance == nil {
            sharedInstance = Timer(delegate: delegate)
        }
        
        return sharedInstance!
    }
    
    var paused = false

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
        set { userDefaults.setDouble(newValue, forKey: "pausedTime") }
    }
    
    private init(delegate: TimerDelegate) {
        self.delegate = delegate

        if let notification = UIApplication.sharedApplication().scheduledLocalNotifications?.first,
            fireDate = notification.fireDate {
                currentTime = fireDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970
                start()
        } else if let pausedTime = userDefaults.objectForKey("pausedTime") as? Double {
            currentTime = pausedTime
            paused = true
        } else {
            currentTime = settings.pomodoroLengthInterval
        }
    }
    
    func start() {
        fireTimer()
        schedulePomodoroNotification(settings.pomodoroLengthInterval)
        
        delegate.timerDidStart()
        
        print("Timer started")
    }
    
    func togglePause() {
        if paused {
            paused = false
            
            // Resume timer
            fireTimer()
            schedulePomodoroNotification(pausedTime)
            
            delegate.timerDidUnpause()
        } else {
            paused = true
            pausedTime = currentTime
            
            // Pause timer
            invalidateTimer()
            cancelNotification()
            
            delegate.timerDidPause()
        }
        
        print("Timer paused")
    }
    
    func stop() {
        invalidateTimer()
        cancelNotification()
        currentTime = settings.pomodoroLengthInterval
        
        delegate.timerDidStop()
        
        print("Timer stopped")
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