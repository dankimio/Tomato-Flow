import SwiftUI
import UIKit

class SettingsViewController: UITableViewController {

  @IBOutlet weak var pomodoroLengthLabel: UILabel!
  @IBOutlet weak var shortBreakLengthLabel: UILabel!
  @IBOutlet weak var longBreakLengthLabel: UILabel!
  @IBOutlet weak var targetPomodorosLabel: UILabel!

  @IBOutlet weak var twitterCell: UITableViewCell!
  @IBOutlet weak var homepageCell: UITableViewCell!
  @IBOutlet weak var appStoreCell: UITableViewCell!

  private let settings = SettingsManager.sharedManager

  private lazy var hostingController: UIHostingController<SettingsRootView> = {
    let controller = UIHostingController(rootView: SettingsRootView())
    controller.view.backgroundColor = .clear
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
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
