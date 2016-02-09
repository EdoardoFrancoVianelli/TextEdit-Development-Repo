//
//  FileDetailViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/18/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class FileDetailViewController: UITableViewController
{
    var CurrentFile = TextFile(FileName: "", FullPath: "", Location: "", FileExtension: "")

    let CellIdentifier = "FileDetails"

    var FileDetails = [(String, String)]()

    override func viewDidLoad()
    {
        self.LoadFileDetails()
        self.tableView.reloadData()
        self.title = CurrentFile.Name
    }

    func LoadFileDetails()
    {
        let Attributes = CurrentFile.GetAttributes()
        //print(Attributes)
        for Attribute in Attributes
        {
            //print(Attribute)
            FileDetails.append(Attribute)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let CurrentCell = tableView.cellForRowAtIndexPath(indexPath)
        {
            let PopUp = UIAlertController(title: CurrentCell.textLabel?.text, message: CurrentCell.detailTextLabel?.text, preferredStyle: UIAlertControllerStyle.Alert)
            PopUp.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(PopUp, animated: false, completion: nil)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let CurrentCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)
        CurrentCell.textLabel?.text = self.FileDetails[indexPath.row].0
        CurrentCell.detailTextLabel?.text = self.FileDetails[indexPath.row].1
        return CurrentCell
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.FileDetails.count
    }

}
