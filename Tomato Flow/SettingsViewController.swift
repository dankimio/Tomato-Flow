import SwiftUI
import UIKit

class SettingsViewController: UITableViewController {

  private let settings = SettingsManager.sharedManager

  private lazy var hostingController: UIHostingController<SettingsView> = {
    let controller = UIHostingController(rootView: SettingsView())
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let nav = navigationController {
      nav.setViewControllers([hostingController], animated: false)
    }
  }

  private func embedSwiftUIView() {
    guard hostingController.view.superview == nil else { return }

    addChild(hostingController)
    view.addSubview(hostingController.view)
    view.bringSubviewToFront(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: guide.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
    ])
    hostingController.didMove(toParent: self)
  }
}

// SwiftUI views moved to separate files: SettingsRootView.swift and DiscreteOptionSelectionView.swift
