//
//  SettingsDetailViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/18/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit


class SettingsDetailViewController : UITableViewController
{
    let SettingsDetailCellID = "SettingsDetailID"

    var SettingOptions = [String]()
    var SelectedSetting = ""
    var SettingName = ""
    var SelectedSettingIndex : NSIndexPath?

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.SettingOptions.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let CurrentIndex = self.SelectedSettingIndex
        {
            tableView.cellForRowAtIndexPath(CurrentIndex)?.accessoryType = UITableViewCellAccessoryType.None
        }
        self.SelectedSettingIndex = indexPath
        if let CurrentCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            CurrentCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.SelectedSetting = CurrentCell.textLabel!.text!
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let CurrentCell = tableView.dequeueReusableCellWithIdentifier(SettingsDetailCellID)
        let Text = SettingOptions[indexPath.row]
        if Text == SelectedSetting
        {
            CurrentCell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.SelectedSettingIndex = indexPath
        }
        CurrentCell?.textLabel?.text = Text
        return CurrentCell!
    }
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(true)
        if let TopViewController = self.view.window?.rootViewController
        {
            if let MainSettings = (TopViewController.childViewControllers[1] as? SettingsViewController)
            {
                MainSettings.SetAttribute(self.SettingName, value: self.SelectedSetting)
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

}








