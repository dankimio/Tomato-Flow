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

    tableView.isHidden = true
    embedSwiftUIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  private func embedSwiftUIView() {
    addChild(hostingController)
    view.addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    hostingController.didMove(toParent: self)
  }
}

// SwiftUI views moved to separate files: SettingsRootView.swift and DiscreteOptionSelectionView.swift
