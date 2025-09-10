import SwiftUI
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?

  // Override point for customization after application launch.
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    registerNotifications()
    configureTabBarColor()

    if let accent = UIColor(named: "AccentColor") {
      UIView.appearance().tintColor = accent
      UINavigationBar.appearance().tintColor = accent
      UITabBar.appearance().tintColor = accent
    }

    // Bootstrap UI programmatically (no storyboard)
    let window = UIWindow(frame: UIScreen.main.bounds)

    let timerViewController = TimerViewController()
    timerViewController.tabBarItem = UITabBarItem(
      title: "Timer",
      image: UIImage(systemName: "timer"),
      selectedImage: nil
    )

    let settingsRoot = UIHostingController(rootView: SettingsView())
    settingsRoot.tabBarItem = UITabBarItem(
      title: "Settings",
      image: UIImage(systemName: "gearshape"),
      selectedImage: nil
    )

    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [timerViewController, settingsRoot]

    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    self.window = window

    return true
  }

  // MARK: - UNUserNotificationCenterDelegate

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("didReceiveNotification")
    timerViewController.presentAlertFromNotification(response.notification)
    completionHandler()
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // Show notification even when app is in foreground
    completionHandler([.banner, .badge, .sound])
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

  private var timerViewController: TimerViewController {
    let tabBarController = window!.rootViewController as! UITabBarController
    return tabBarController.viewControllers!.first as! TimerViewController
  }

  private func registerNotifications() {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      granted, error in
      if let error = error {
        print("Notification authorization error: \(error)")
      } else {
        print("Notification authorization granted: \(granted)")
      }
    }
  }

  private func resetBadgeNumber() {
    if #available(iOS 17.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    } else {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }

  private func configureTabBarColor() {
    UITabBar.appearance().tintColor = UIColor(
      red: 240 / 255.0, green: 90 / 255.0, blue: 90 / 255.0, alpha: 1)
  }

}
