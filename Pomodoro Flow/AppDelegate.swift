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
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    registerNotifications()
    configureTabBarColor()

    return true
  }

  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {

    print("didReceiveLocalNotification")
    timerViewController.presentAlertFromNotification(notification)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions
    // (such as an incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers,
    // and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application
    // to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while
    // the application was inactive. If the application was previously in the background,
    // optionally refresh the user interface.

    resetBadgeNumber()
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate.
    // Save data if appropriate. See also applicationDidEnterBackground:.

    print("applicationWillTerminate")
    timerViewController.pause()
  }

  // MARK: - Helpers

  fileprivate var timerViewController: TimerViewController {
    let tabBarController = window!.rootViewController as! UITabBarController
    return tabBarController.viewControllers!.first as! TimerViewController
  }

  fileprivate func registerNotifications() {
    let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                          categories: nil)
    UIApplication.shared.registerUserNotificationSettings(notificationSettings)
  }

  fileprivate func resetBadgeNumber() {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  fileprivate func configureTabBarColor() {
    UITabBar.appearance().tintColor = UIColor(
      red: 240/255.0, green: 90/255.0, blue: 90/255.0, alpha: 1)
  }

}
