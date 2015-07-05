//
//  SettingsViewController.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2015-07-06.
//  Copyright (c) 2015 Dan K. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var tickingSoundCell: UITableViewCell!
    @IBOutlet weak var autostartBreaksCell: UITableViewCell!
    @IBOutlet weak var autostartPomodorosCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tickingSoundCell.accessoryView = UISwitch(frame: CGRectZero)
        autostartBreaksCell.accessoryView = UISwitch(frame: CGRectZero)
        autostartPomodorosCell.accessoryView = UISwitch(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
