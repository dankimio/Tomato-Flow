//
//  PickerViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

protocol PickerViewControllerDelegate: class {
  func pickerDidFinishPicking(_ picker: PickerViewController)
}

class PickerViewController: UITableViewController {

  var options: [Int]!
  var specifier = "minutes"

  var type: PickerType!
  var selectedValue: Int!
  var selectedIndexPath: IndexPath?
  var delegate: PickerViewControllerDelegate?

  fileprivate struct PickerOptions {
    static let pomodoroLength = [25, 30, 35, 40].map { $0 * 60 }
    static let shortBreakLength = [5, 10, 15, 20].map { $0 * 60 }
    static let longBreakLength = [10, 15, 20, 25, 30].map { $0 * 60 }
    static let targetPomodoros = (2...14).map { $0 }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    switch type! {
    case .pomodoroLength: options = PickerOptions.pomodoroLength
    case .shortBreakLength: options = PickerOptions.shortBreakLength
    case .longBreakLength: options = PickerOptions.longBreakLength
    case .targetPomodoros: options = PickerOptions.targetPomodoros
    }

    if let index = options.index(of: selectedValue), type != .targetPomodoros {
      selectedIndexPath = IndexPath(row: index, section: 0)
    }
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath)

    // Configure the cell
    let value = options[indexPath.row]
    let formattedValue = (type == PickerType.targetPomodoros ? value : value / 60)
    cell.textLabel?.text = "\(formattedValue) \(specifier)"

    let currentValue = options[indexPath.row]

    if currentValue == selectedValue {
      cell.accessoryType = .checkmark
      selectedIndexPath = indexPath
    } else {
      cell.accessoryType = .none
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    // Return if new value is equal to selected value
    if options[indexPath.row] == selectedValue {
      return
    }

    // Put a checkmark on the new selection
    if let newCell = tableView.cellForRow(at: indexPath) {
      newCell.accessoryType = .checkmark
    }

    // Remove a checkmark from the old cell
    if let previousIndexPath = selectedIndexPath,
      let oldCell = tableView.cellForRow(at: previousIndexPath) {
      oldCell.accessoryType = .none
    }

    selectedIndexPath = indexPath
    selectedValue = options[indexPath.row]
    updateSettings()
  }

  // Navigating back
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if isMovingFromParentViewController {
      delegate?.pickerDidFinishPicking(self)
    }
  }

  fileprivate func updateSettings() {
    let settings = Settings.sharedInstance

    switch type! {
    case .pomodoroLength:
      settings.pomodoroLength = selectedValue
    case .shortBreakLength:
      settings.shortBreakLength = selectedValue
    case .longBreakLength:
      settings.longBreakLength = selectedValue
    case .targetPomodoros:
      settings.targetPomodoros = selectedValue
    }
  }

}
