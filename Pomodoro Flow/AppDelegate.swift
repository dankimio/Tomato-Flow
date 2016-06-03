//
//  AppDelegate.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-06-24.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Override point for customization after application launch.
    func application(application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        registerNotifications()
        configureTabBarColor()

        return true
    }

    func application(application: UIApplication,
            didReceiveLocalNotification notification: UILocalNotification) {

        print("didReceiveLocalNotification")
        timerViewController.presentAlertFromNotification(notification)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application
        // and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers,
        // and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough application state information to restore your application
        // to its current state in case it is terminated later.
        // If your application supports background execution, this method is called
        // instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state;
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while
        // the application was inactive. If the application was previously in the background,
        // optionally refresh the user interface.

        resetBadgeNumber()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate.
        // Save data if appropriate. See also applicationDidEnterBackground:.

        print("applicationWillTerminate")
        timerViewController.pause(self)
    }

    // MARK: - Helpers

    private var timerViewController: TimerViewController {
        let tabBarController = window!.rootViewController as! UITabBarController
        return tabBarController.viewControllers!.first as! TimerViewController
    }

    private func registerNotifications() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound],
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }

    private func resetBadgeNumber() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    private func configureTabBarColor() {
        UITabBar.appearance().tintColor = UIColor(
            red: 240/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1)
    }

}
