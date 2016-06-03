//
//  SettingsViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PickerViewControllerDelegate {

    @IBOutlet weak var pomodoroLengthLabel: UILabel!
    @IBOutlet weak var shortBreakLengthLabel: UILabel!
    @IBOutlet weak var longBreakLengthLabel: UILabel!
    @IBOutlet weak var targetPomodorosLabel: UILabel!
    
    // About section
    @IBOutlet weak var twitterCell: UITableViewCell!
    @IBOutlet weak var homepageCell: UITableViewCell!
    @IBOutlet weak var appStoreCell: UITableViewCell!

    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let settings = Settings.sharedInstance
    
    private struct About {
        static let twitterURL = "https://twitter.com/itsdnco"
        static let homepageURL = "http://itsdn.co"
        static let appStoreURL =
            "https://itunes.apple.com/us/app/pomodoro-flow/id1095742214?ls=1&mt=8"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }

    private func setupLabels() {
        pomodoroLengthLabel.text = "\(settings.pomodoroLength / 60) minutes"
        shortBreakLengthLabel.text = "\(settings.shortBreakLength / 60) minutes"
        longBreakLengthLabel.text = "\(settings.longBreakLength / 60) minutes"
        targetPomodorosLabel.text = "\(settings.targetPomodoros) pomodoros"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let picker = segue.destinationViewController as? PickerViewController {
            switch segue.identifier! {
            case "PomodoroLengthPicker":
                picker.selectedValue = settings.pomodoroLength
                picker.type = PickerType.PomodoroLength
            case "ShortBreakLengthPicker":
                picker.selectedValue = settings.shortBreakLength
                picker.type = PickerType.ShortBreakLength
            case "LongBreakLengthPicker":
                picker.selectedValue = settings.longBreakLength
                picker.type = PickerType.LongBreakLength
            case "TargetPomodorosPicker":
                picker.specifier = "pomodoros"
                picker.selectedValue = settings.targetPomodoros
                picker.type = PickerType.TargetPomodoros
            default:
                break
            }
            picker.delegate = self
        }
    }

    func pickerDidFinishPicking(picker: PickerViewController) {
        setupLabels()
    }
    
    // MARK: - Table view delegate

    override func tableView(tableView: UITableView,
                            didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        switch cell {
        case twitterCell: openURL(About.twitterURL)
        case homepageCell: openURL(About.homepageURL)
        case appStoreCell: openURL(About.appStoreURL)
        default: return
        }
    }
    
    // MARK: - Helpers
    
    private func openURL(url: String) {
        let application = UIApplication.sharedApplication()
        
        if let url = NSURL(string: url) {
            application.openURL(url)
        }
    }

}
