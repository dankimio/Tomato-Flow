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

    // App owns the UI reference at the scene level, not via AppDelegate
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    timerViewController?.pause()
  }

  func handleNotification(_ notification: UNNotification) {
    timerViewController?.presentAlertFromNotification(notification)
  }
}
