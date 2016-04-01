//
//  PickerViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

protocol PickerViewControllerDelegate: class {
    func pickerDidFinishPicking(picker: PickerViewController)
}

class PickerViewController: UITableViewController {

    var options: [Int]!
    var specifier = "minutes"

    var type: PickerType!
    var selectedValue: Int!
    var selectedIndexPath: NSIndexPath?
    var delegate: PickerViewControllerDelegate?

    private struct PickerOptions {
        static let pomodoroLength = [1, 25, 30, 35, 40].map { $0 * 60 }
        static let shortBreakLength = [5, 10, 15, 20].map { $0 * 60 }
        static let longBreakLength = [10, 15, 20, 25, 30].map { $0 * 60 }
        static let targetPomodoros = (2...14).map { $0 }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch type! {
        case .PomodoroLength: options = PickerOptions.pomodoroLength
        case .ShortBreakLength: options = PickerOptions.shortBreakLength
        case .LongBreakLength: options = PickerOptions.longBreakLength
        case .TargetPomodoros: options = PickerOptions.targetPomodoros
        }

        if let index = options.indexOf(selectedValue) where type != .TargetPomodoros {
            selectedIndexPath = NSIndexPath(forRow: index, inSection: 0)
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell",
            forIndexPath: indexPath)

        // Configure the cell
        let value = options[indexPath.row]
        let formattedValue = (type == PickerType.TargetPomodoros ? value : value / 60)
        cell.textLabel?.text = "\(formattedValue) \(specifier)"

        let currentValue = options[indexPath.row]

        if currentValue == selectedValue {
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView,
                            didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // Return if new value is equal to selected value
        if options[indexPath.row] == selectedValue {
            return
        }

        // Put a checkmark on the new selection
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
            newCell.accessoryType = .Checkmark
        }

        // Remove a checkmark from the old cell
        if let previousIndexPath = selectedIndexPath,
                oldCell = tableView.cellForRowAtIndexPath(previousIndexPath) {
            oldCell.accessoryType = .None
        }

        selectedIndexPath = indexPath
        selectedValue = options[indexPath.row]
        updateSettings()
    }

    // Navigating back
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParentViewController() {
            delegate?.pickerDidFinishPicking(self)
        }
    }

    private func updateSettings() {
        let settings = SettingsManager.sharedManager

        switch type! {
        case .PomodoroLength:
            settings.pomodoroLength = selectedValue
        case .ShortBreakLength:
            settings.shortBreakLength = selectedValue
        case .LongBreakLength:
            settings.longBreakLength = selectedValue
        case .TargetPomodoros:
            settings.targetPomodoros = selectedValue
        }
    }

}
