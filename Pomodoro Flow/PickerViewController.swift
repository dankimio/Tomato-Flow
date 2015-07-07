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
        static let pomodoroLength = [25, 30, 35, 40]
        static let shortBreakLength = [5, 10, 15, 20]
        static let longBreakLength = [10, 15, 20, 25, 30]
        static let targetPomodoros = (2...21).map { $0 }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type! {
        case .PomodoroLength: options = PickerOptions.pomodoroLength
        case .ShortBreakLength: options = PickerOptions.shortBreakLength
        case .LongBreakLength: options = PickerOptions.longBreakLength
        case .TargetPomodoros: options = PickerOptions.targetPomodoros
        }
        
        selectedIndexPath = NSIndexPath(forRow: find(options, selectedValue)!, inSection: 0)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell
        cell.textLabel?.text = "\(options[indexPath.row]) \(specifier)"
        
        let currentValue = options[indexPath.row]
        
        if currentValue == selectedValue {
            cell.accessoryType = .Checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if options[indexPath.row] == selectedValue {
            return
        }
        
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
            newCell.accessoryType = .Checkmark
        }
        
        find(options, selectedValue)
        
        if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath!) {
            oldCell.accessoryType = .None
        }
        
        selectedIndexPath = indexPath
        selectedValue = options[indexPath.row]
        updateSettings()
    }

    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
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
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("targetPomodorosUpdated", object: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
