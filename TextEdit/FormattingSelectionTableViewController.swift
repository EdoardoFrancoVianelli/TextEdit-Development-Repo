//
//  FormattingSelectionTableViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/25/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

enum TaskIdentifier : Int{
    case FontEditing = 1, ColorEditing = 2
}

import UIKit

class FormattingSelectionTableViewController: UITableViewController {

    var ID = TaskIdentifier.FontEditing
    let CellReuseIdentifier = "FormattingSelectionCell"
    var ContentsSelection = [NSAttributedString]()
    var CurrentSelected : NSIndexPath?
    var SourceString = NSMutableAttributedString(string: "")

    override func viewWillDisappear(animated: Bool) {
        //Send back the result

        if let Destination = self.presentingViewController as? FormattingViewController
        {
            if let SelectedIndex = self.CurrentSelected
            {
                if let Result = self.tableView.cellForRowAtIndexPath(SelectedIndex)?.textLabel?.attributedText
                {
                    let range = NSRange(location: 0, length: SourceString.string.characters.count)
                    if ID == TaskIdentifier.FontEditing
                    {
                        let FontAttribute = Result.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! UIFont
                        let PreviousFont = SourceString.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as! UIFont
                        let ResultingFont = UIFont(name: FontAttribute.fontName, size: PreviousFont.pointSize)
                        SourceString.addAttribute(NSFontAttributeName, value: ResultingFont!, range: range)
                    }
                    else if ID == TaskIdentifier.ColorEditing
                    {
                        if let ColorAttribute = Result.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: nil)
                        {
                            SourceString.addAttribute(NSForegroundColorAttributeName, value: ColorAttribute, range: range)
                        }
                    }
                    Destination.CurrentString = SourceString
                }
            }
        }else {
            //print("not a formatting controller")
        }

    }

    func SetContentsSelection(newContents : [NSAttributedString])
    {
        self.ContentsSelection = newContents
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //print(self.ContentsSelection.count)
        return self.ContentsSelection.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier, forIndexPath: indexPath)

        cell.textLabel?.attributedText = self.ContentsSelection[indexPath.row]

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        if let CurrentSelectedIndex = self.CurrentSelected
        {
            tableView.cellForRowAtIndexPath(CurrentSelectedIndex)?.accessoryType = UITableViewCellAccessoryType.None
        }
        self.CurrentSelected = indexPath
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
