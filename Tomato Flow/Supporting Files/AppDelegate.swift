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
    configureColor()

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
    let windowScene = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .first { $0.activationState != .unattached }

    let window = windowScene?.windows.first { $0.isKeyWindow } ?? windowScene?.windows.first
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

  private func configureColor() {
    guard let accent = UIColor(named: "AccentColor") else { return }

    UIView.appearance().tintColor = accent
    UINavigationBar.appearance().tintColor = accent
    UITabBar.appearance().tintColor = accent
  }

}
