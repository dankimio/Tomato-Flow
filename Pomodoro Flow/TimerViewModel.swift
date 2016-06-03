//
//  TimerViewModel.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2016-05-14.
//  Copyright © 2016 Dan K. All rights reserved.
//

import UIKit
import RxSwift

class TimerViewModel {
    
    var timerLabel: Observable<String>!
    var timerLabelColor: Observable<UIColor>!

    var pomodorosCount = Variable(0)
    var targetPomodorosCount = Variable(0)
    var paused = Variable(false)
    
    private var currentTime = Variable(0)
    private var state = Variable(State.Default)
    
    private let pomodoro = Pomodoro.sharedInstance
    private let settings = Settings.sharedInstance
    private let scheduler = Scheduler.sharedInstance
    
    private let disposeBag = DisposeBag()
    private var timer: NSTimer?
    
    init() {
        if let pausedTime = pomodoro.pausedTime {
            currentTime.value = pausedTime
        } else {
            currentTime.value = settings.pomodoroLength
        }
        
        paused.value = pomodoro.paused
        pomodorosCount.value = pomodoro.pomodorosCount
        targetPomodorosCount.value = settings.targetPomodoros
    
        setup()
    }
    
    func start() {
        switch state.value {
        case .Default: scheduler.schedulePomodoro()
        case .ShortBreak: scheduler.scheduleShortBreak()
        case .LongBreak: scheduler.scheduleLongBreak()
        }

        fireTimer()
    }
    
    func pause() {
        pomodoro.pausedTime = currentTime.value
        scheduler.suspend()
        timer?.invalidate()
    }

    func unpause() {
        switch state.value {
        case .Default: scheduler.schedulePomodoro(pomodoro.pausedTime)
        case .ShortBreak: scheduler.scheduleShortBreak(pomodoro.pausedTime)
        case .LongBreak: scheduler.scheduleLongBreak(pomodoro.pausedTime)
        }
        
        fireTimer()
    }
    
    func stop() {
        scheduler.suspend()
        currentTime.value = settings.pomodoroLength
        timer?.invalidate()
    }
    
    @objc internal func tick() {
        currentTime.value -= 1
    }
    
    private func setup() {
        timerLabel = currentTime
            .asObservable()
            .map { String(format: "%02d:%02d", $0 / 60, $0 % 60) }
        
        timerLabelColor = state
            .asObservable()
            .map { $0 == State.Default ? UIColor.primaryColor : UIColor.breakColor }
        
        state
            .asObservable()
            .subscribeNext { state in
                if state == .ShortBreak || state == .LongBreak {
                    self.pomodorosCount.value += 1
                }
            }
            .addDisposableTo(disposeBag)
        
        currentTime
            .asObservable()
            .subscribeNext { time in
                if time <= 0 {
                    self.nextState()
                }
            }
            .addDisposableTo(disposeBag)
        
        pomodorosCount
            .asObservable()
            .subscribeNext { self.pomodoro.pomodorosCount = $0 }
            .addDisposableTo(disposeBag)
    }
    
    private func nextState() {
        switch self.state.value {
        case .Default: self.state.value = (pomodorosCount.value % 4 == 0 ? .LongBreak : .ShortBreak)
        case .ShortBreak, .LongBreak: self.state.value = .Default
        }
    }
    
    private func fireTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1,
                                                       target: self,
                                                       selector: #selector(tick),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
}
