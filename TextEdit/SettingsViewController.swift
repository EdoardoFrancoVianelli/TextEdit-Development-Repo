//
//  SettingsViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/18/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, NSXMLParserDelegate
{
    var CurrentSettings = Settings()

    //private var ReadabilityMappings = Dictionary<String, String>()
    //private var AttributeOptions = Dictionary<String, [String]>()
    //private var SettingsAttributeNames = [(String, String, [String])]()
    //private var Attributes = Dictionary<String, String>()

    private var Element = ""
    let SettingCellId = "SettingCell"

    func SetAttribute(name : String, value : String)
    {
        CurrentSettings.SetSettingForAttribute(name, value: value)
        self.tableView.reloadData()
        self.WriteSettings()
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError)
    {
        //print(parseError)
    }

    func ReadSettings()
    {
        if let FileData = NSData(contentsOfFile: self.SettingsFilePath())
        {
            //print("Initiating parsing")
            let parser = NSXMLParser(data: FileData)
            
            parser.delegate = self
            parser.parse()
        }
    }

    func WriteSettings()
    {
        //TO DO: Write the changes
        CurrentSettings.WriteSettingsToFile()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrentSettings.SettingCount
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print("About to crash on line 62")
        let CurrentCell = tableView.dequeueReusableCellWithIdentifier(SettingCellId)!

        let AllSettingNames = self.CurrentSettings.AlphabeticalSettingNames
        let CurrentSetting = AllSettingNames.ObjectAtIndex(indexPath.row)

        CurrentCell.textLabel?.text = CurrentSetting
        //print("About to crash on line 69")
        CurrentCell.detailTextLabel?.text = self.CurrentSettings.GetSettingForAttribute(CurrentSetting)!

        return CurrentCell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let CurrentIndexPath = self.tableView.indexPathForSelectedRow
        {
            if let CurrentCellText = self.tableView.cellForRowAtIndexPath(CurrentIndexPath)?.textLabel?.text
            {
                if let Options = self.CurrentSettings.OptionsForSettingName(CurrentCellText)
                {
                    if let destination = (segue.destinationViewController as? SettingsDetailViewController)
                    {
                        destination.SettingOptions = Options
                        let CurrentSettingSelectedSettingKey = CurrentCellText
                        //print("About to crash on line 84")
                        let CurrentSelected = self.CurrentSettings.GetSettingForAttribute(CurrentSettingSelectedSettingKey)!
                        destination.SelectedSetting = CurrentSelected
                        destination.SettingName = CurrentCellText
                    }
                }
            }
        }


    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.CurrentSettings = Settings()
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    func SettingsFilePath() -> String
    {
        return GetDocumentsDirectory() + "/Settings.plist"
    }

    func SettingsFileExists() -> Bool
    {
        return NSData(contentsOfFile: SettingsFilePath()) != nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



















