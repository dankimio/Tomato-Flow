import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

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

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()
    self.window = window
  }
}
