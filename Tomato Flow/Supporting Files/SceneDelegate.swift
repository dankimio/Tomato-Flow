import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  private weak var timerViewController: TimerViewController?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let timerViewController = TimerViewController()
    self.timerViewController = timerViewController
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

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    
    self.window = window
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Clear any badges when the scene becomes active again
    if #available(iOS 17.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    } else {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }

  func handleNotification(_ notification: UNNotification) {
    // Ensure the Timer tab is visible so the alert presents on the right VC
    if let tab = window?.rootViewController as? UITabBarController {
      tab.selectedIndex = 0
    }
    timerViewController?.presentAlertFromNotification(notification)
  }
}
