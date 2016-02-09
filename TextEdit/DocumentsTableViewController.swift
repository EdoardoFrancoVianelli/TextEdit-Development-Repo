//
//  DocumentsTableViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/17/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit
import LocalAuthentication

let CellIdentifier = "DocumentCellIdentifier"
let DocumentSegueIdentifier = "DocumentViewSegue"
let FileSegue = "FileDetailSegue"
let PDFSegue = "PDFSegue"

class DocumentsTableViewController: UITableViewController, UISearchBarDelegate {

    var AllSearchedFolderElements = [FolderElement]()
    var searching = false
    var _new_file : TextFile?

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var ReturnToFolderButton: UIBarButtonItem!

    var GlobalSettings = Settings()

    var PromptBeforeDeletion = true

    var FolderStack = [Folder]()

    var pt_board : [FolderElement]?

    var Pasteboard : [FolderElement]?
    {
        get
        {
            return self.pt_board
        }
        set
        {
            self.pt_board = newValue
            self.moreButton.enabled = self.pt_board != nil
        }
    }

    var Copying = false

    @IBOutlet weak var moreButton: UIBarButtonItem!
    func ApplySettings()
    {
        self.ApplyFileSorting()
    }
    
    @IBAction func ReturnToPreviousFolder(sender: AnyObject)
    {
        self.WentUpFolder()
        self.UpdateBackButton()
    }

    func CopySelection(copying : Bool)
    {
        if let SelectedIndices = self.tableView.indexPathsForSelectedRows
        {
            for IndexPath in SelectedIndices
            {
                if let toAdd = self.FolderStack.last?.Contents[IndexPath.row]
                {
                    self.CopyElement(toAdd, copy: copying)
                }
            }
        }
    }

    func CopyElement(element : FolderElement, copy : Bool)
    {
        if self.Pasteboard == nil
        {
            self.Pasteboard = [FolderElement]()
        }
        self.Pasteboard?.append(element)
    }

    func PasteElement(item : FolderElement)
    {
        let fileManager = NSFileManager()

        let OldPath = item.Path
        let NewPath = self.FolderStack.last!.Path

        do
        {
            try fileManager.copyItemAtPath(OldPath, toPath: NewPath + "/" + item.Name)
        }
        catch
        {
            print(error)
        }

        if !self.Copying
        {
            do { try fileManager.removeItemAtPath(item.Path) }
            catch {
                //print(error)
            }
            self.Pasteboard = nil
        }

        self.LoadDocumentsFromRefresh()
    }

    @IBAction func ViewMore(sender: AnyObject)
    {
        //copy and move
        //if there is something in the pasteboard, give a paste option

        let MoreViewer = UIAlertController(title: "Select an action", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        MoreViewer.addAction(UIAlertAction(title: "Copy", style: UIAlertActionStyle.Default, handler: { (action : UIAlertAction!) in
            self.CopySelection(true)
        }))

        if self.Copying == false
        {
            MoreViewer.addAction(UIAlertAction(title: "Move", style: UIAlertActionStyle.Default, handler: {(action : UIAlertAction) in
                self.CopySelection(false)
            }))
        }

        if let ItemsToPaste = self.Pasteboard
        {
            MoreViewer.addAction(UIAlertAction(title: "Paste", style: UIAlertActionStyle.Default, handler: { (action : UIAlertAction!) in
                for item in ItemsToPaste
                {
                    self.PasteElement(item)
                }
            }))
        }

        MoreViewer.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))

        self.presentViewController(MoreViewer, animated: false, completion: nil)
    }

    func UpdateBackButton()
    {
        self.ReturnToFolderButton.enabled = self.FolderStack.count > 1
        self.ReturnToFolderButton.title = "Back"
    }

    func ApplyFileSorting()
    {
        var SortingCriteria = Dictionary<String, (FolderElement, FolderElement) -> Bool>()

        //["Name, Ascending", "Name, Descending", "Date, Ascending", "Date, Descending", "Size, Ascending", "Size, Descending"]

        SortingCriteria["Name, Ascending"] = SortByAscendingName
        SortingCriteria["Name, Descending"] = SortByDescendingName
        SortingCriteria["Date Created, Ascending"] = SortByAscendingCreationDate
        SortingCriteria["Date Created, Descending"] = SortByDescendingCreationDate
        SortingCriteria["Date Modified, Ascending"] = SortByAscendingModificationDate
        SortingCriteria["Date Modified, Descending"] = SortByDescendingModificationDate
        SortingCriteria["Size, Ascending"] = SortByAscendingSize
        SortingCriteria["Size, Descending"] = SortByDescendingSize

        if let CurrentSortingSettings = self.GlobalSettings.GetSettingForAttribute("File Sorting")
        {
            if let SortingMechanism = SortingCriteria[CurrentSortingSettings]
            {
                //print("Sorting by \(CurrentSortingSettings)")
                self.FolderStack.last?.SortContents(SortingMechanism)
            }
        }

        self.tableView.reloadData()
    }

    func EvaluateDeletionPolicy()
    {
        if let DeletionValue = self.GlobalSettings.GetSettingForAttribute("Ask before deleting a file or folder")
        {
            self.PromptBeforeDeletion = (DeletionValue == "Yes")
        }
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        self.DoneSearching()
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        self.SearchBar.resignFirstResponder()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        self.searching = true
        self.AllSearchedFolderElements = [FolderElement]()

        if searchText == ""
        {
            self.AllSearchedFolderElements = self.FolderStack.last!.Contents
        }
        else
        {
            //print("Initiating search with \(searchText)")
            //get the current setting
            let CaseSensitive = self.GlobalSettings.GetSettingForAttribute("File Searching Options")! == "Case Sensitive"
            if let CurrentContents = self.FolderStack.last?.Contents
            {
                for file in CurrentContents
                {
                    if let File = (file as? TextFile)
                    {
                        if File.FullFilename.ContainsString(searchText, caseSensitive: CaseSensitive)
                        {
                            self.AllSearchedFolderElements.append(file)
                        }
                    }
                }
            }
        }
        self.tableView.reloadData()
    }

    func ConfigureNavigationControllerLook()
    {
        self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.blueColor()
        self.navigationController?.toolbar.tintColor = UIColor.blueColor()
        self.navigationController?.toolbar.backgroundColor = UIColor.blueColor()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.ConfigureNavigationControllerLook()

        self.SearchBar.delegate = self

        self.clearsSelectionOnViewWillAppear = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "EditTableView:")

        self.UpdateBackButton()

        self.InitializePullToRefreshFiles()

        if self.FolderStack.isEmpty
        {
            self.FolderStack = [Folder]()
            self.ConfigureFolderStack()
        }

        self.GlobalSettings.LoadSettings()

        self.Pasteboard = nil

        self.EvaluateDeletionPolicy()

        self.LoadDocuments(self.FolderStack.last)
    }

    func EditTableView(sender : UIBarButtonItem)
    {
        self.tableView.editing = !self.tableView.editing
        if self.tableView.editing{ sender.title = "Done" }
        else { sender.title = "Edit" }
    }

    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.editButtonItem().enabled = true
    }

    func InitializePullToRefreshFiles()
    {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "LoadDocumentsFromRefresh", forControlEvents: UIControlEvents.ValueChanged)
    }

    func LoadDocumentsFromRefresh()
    {
        self.LoadDocuments(self.FolderStack.last)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if searching
        {
            return self.AllSearchedFolderElements.count
        }else if let CurrentCount = self.FolderStack.last?.Contents.count
        {
            return CurrentCount
        }

        return 0
    }


    func ThumbnailName(file : TextFile) -> String
    {
        return file.Path + "-Thumbnail.jpg"
    }

    func ImageForRowAtIndexPath(indexPath : NSIndexPath) -> UIImage?
    {
        var Element = self.FolderStack.last?.Contents.ObjectAtIndex(indexPath.row)

        if searching
        {
            Element = self.AllSearchedFolderElements.ObjectAtIndex(indexPath.row)
        }

        if let File = Element as? TextFile
        {
            //print(File.description + " is a file")
            let ImageName = ThumbnailName(File)
            if let ImageForFile = UIImage(named: ImageName)
            {
                return ImageForFile
            }
            else
            {
                return UIImage(named: "Document.JPG")
            }
        }
        else
        {
            //print(fldr.description + " is a folder")
            return UIImage(named: "Folder.JPG")
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let copy_action = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Copy", handler: {(action : UITableViewRowAction, index_path : NSIndexPath) in

            self.CopyElement(self.FolderStack.last!.Contents[indexPath.row], copy:true)
            tableView.reloadData()
        })
        copy_action.backgroundColor = UIColor.grayColor()

        let move_action = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Move", handler: {(action : UITableViewRowAction, index_path : NSIndexPath) in

            self.CopyElement(self.FolderStack.last!.Contents[indexPath.row], copy:true)
            self.Copying = false
            tableView.reloadData()
        })
        move_action.backgroundColor = UIColor.orangeColor()

        let delete_action = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: {

            (action : UITableViewRowAction, index_path : NSIndexPath) in

            self.DeleteItem(index_path)
            tableView.reloadData()
        })
        delete_action.backgroundColor = UIColor.redColor()
        return [copy_action, move_action, delete_action]
    }

    func DeleteItem(indexPath : NSIndexPath)
    {
        self.UpdateBackButton()
        if let CurrentElementToDelete = self.FolderStack.last?.Contents[indexPath.row]
        {
            if self.PromptBeforeDeletion
            {
                let isFolder = CurrentElementToDelete is Folder
                var FileRemovalTitle = "Are you sure you want to delete \(CurrentElementToDelete.description)?"
                if isFolder { FileRemovalTitle += " This will also delete all the contents of \(CurrentElementToDelete.description)" }
                let FileRemovalConfirmation = UIAlertController(title: FileRemovalTitle, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                FileRemovalConfirmation.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action : UIAlertAction) in

                    self.DeleteItem(CurrentElementToDelete, indexPath: indexPath)

                    }

                    ))
                FileRemovalConfirmation.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { (action : UIAlertAction) in
                }))

                self.presentViewController(FileRemovalConfirmation, animated: false, completion: nil)
            }
            else
            {
                self.DeleteItem(CurrentElementToDelete, indexPath: indexPath)
            }
        }
    }

    func DeleteItem(item : FolderElement, indexPath : NSIndexPath)
    {
        tableView.beginUpdates()

        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

        self.RemoveItem(item)

        self.FolderStack.last?.RemoveFileAtIndex(indexPath.row)

        tableView.endUpdates()

        self.UpdateBackButton()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath)

        var CurrentElement = self.FolderStack.last?.Contents.ObjectAtIndex(indexPath.row)

        if self.searching
        {
            if let CurrentFile = (self.AllSearchedFolderElements.ObjectAtIndex(indexPath.row) as? TextFile)
            {
                CurrentElement = CurrentFile
            }
        }

        if let CurrentFile = CurrentElement as? TextFile
        {
            //print("About to set details of the file")
            let DateFormat = NSDateFormatter()
            DateFormat.dateStyle = NSDateFormatterStyle.MediumStyle

            let FormattedName = NSMutableAttributedString(string: CurrentFile.Name)
            FormattedName.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(16), range: NSRange(location: 0, length: CurrentFile.Name.characters.count))
            FormattedName.appendAttributedString(NSMutableAttributedString(string: "\nCreated: \(DateFormat.stringFromDate(CurrentFile.DateCreated))", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(12)]))
            FormattedName.appendAttributedString(NSMutableAttributedString(string: "\nModified: \(DateFormat.stringFromDate(CurrentFile.DateModified))", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(12)]))

            cell.textLabel?.attributedText = FormattedName

            if let label = cell.textLabel
            {
                if (label.frame.origin.x + label.frame.size.width) / cell.frame.size.width <= 0.6
                {
                    cell.detailTextLabel?.text = CurrentFile.FileSizeDescriptor
                }
            }

        }
        else if let CurrentFolder = CurrentElement as? Folder
        {
            cell.textLabel?.text = CurrentFolder.Name
            if let label = cell.textLabel
            {
                if (label.frame.origin.x + label.frame.size.width) / cell.frame.size.width < 0.6
                {
                    cell.detailTextLabel?.text = folderSize(CurrentFolder.Path)
                }
            }
        }

        cell.imageView?.image = ImageForRowAtIndexPath(indexPath)

        return cell
    }

    

    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath){
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.editButtonItem().enabled = false
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !self.searching
    }

    // MARK: Other table view stuff


    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.SearchBar.resignFirstResponder()
    }

    func DoneSearching()
    {
        self.searching = false
        self.SearchBar.resignFirstResponder()
        self.AllSearchedFolderElements = [FolderElement]()
        self.SearchBar.text = ""
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let DocumentSegue = "DocumentViewSegue"

        self.DoneSearching()

        var CurrentItem = self.FolderStack.last?.Contents[indexPath.row]

        if self.searching
        {
            CurrentItem = self.AllSearchedFolderElements[indexPath.row]
        }

        if !self.tableView.editing
        {
            if let _ = CurrentItem as? TextFile
            {
                //print("is a file")
                self.performSegueWithIdentifier(DocumentSegue, sender: self)
            }
            else if let newfolder = CurrentItem as? Folder
            {
                //print("found folder \(newfolder.Path)")
                self.WentIntoFolder(newfolder)
            }
        }
        else if let count = self.tableView.indexPathsForSelectedRows?.count
        {
            self.moreButton.enabled = count > 0
        }
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.editing
        {
            if let count = self.tableView.indexPathsForSelectedRows?.count
            {
                self.moreButton.enabled = count > 0
            }
            else { self.moreButton.enabled = false }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == DocumentSegueIdentifier
        {
            if let IndexPath = self.tableView.indexPathForSelectedRow
            {
                if let File = self.FolderStack.last?.Contents.ObjectAtIndex(IndexPath.row) as? TextFile
                {
                    (segue.destinationViewController as! DocumentEditorViewController).CurrentFile = File
                }
                self.tableView.deselectRowAtIndexPath(IndexPath, animated: true)
            }
            else if let NewFile = self._new_file
            {
                (segue.destinationViewController as! DocumentEditorViewController).CurrentFile = NewFile
                (segue.destinationViewController as! DocumentEditorViewController).CreatingFile = true
                self._new_file = nil
            }


        }
        else if segue.identifier == FileSegue
        {
            //print("hit")
            if let cell = sender as? UITableViewCell
            {

                if let Index = self.tableView.indexPathForCell(cell)?.row
                {

                    if let CurrentFile = self.FolderStack.last?.Contents.ObjectAtIndex(Index) as? TextFile
                    {
                        (segue.destinationViewController as! FileDetailViewController).CurrentFile = CurrentFile
                    }
                }
            }
        }
    }

    //MARK: File Handling

    func CreateFileWithName(name : String, FileExtension : String) -> TextFile?
    {
        if let CurrentPath = self.FolderStack.last?.Path
        {
            let FullPath = CurrentPath + "/" + name + ".\(FileExtension)"
                //print("entering with path: \(FullPath)")
            do {

                try "".writeToFile(FullPath, atomically: true, encoding: NSUTF32StringEncoding)
                //print("Successfull creation")
                return TextFile(FileName: name, FullPath: FullPath, Location: CurrentPath, FileExtension: FileExtension)
            }
            catch { "Could not write to \(FullPath)" }

        }
        else{
            //print("No directory")
        }

        return nil
    }

    func CreateFolderWithName(name : String)
    {
        //print("Creating \(name)")
        if let CurrentPath = self.FolderStack.last?.Path
        {
            do
            {
                try NSFileManager.defaultManager().createDirectoryAtPath(CurrentPath + "/\(name)", withIntermediateDirectories: false, attributes: nil)
                self.LoadDocuments(self.FolderStack.last)
                self.WentIntoFolder(self.FolderStack.last!)
            }
            catch
            {
                //print("Folder could not be created")
            }
        }
    }

    func CreateNewFileWithName(FileName : String)
    {
        let FileExtension = self.GlobalSettings.GetSettingForAttribute("File Format")!
        //print("Creating \(FileName).\(FileExtension)")
        if let NewFile = self.CreateFileWithName(FileName, FileExtension: FileExtension)
        {
            self.LoadDocuments(self.FolderStack.last)
            self._new_file = NewFile
            self.performSegueWithIdentifier(DocumentSegueIdentifier, sender: self)
        }
        else
        {
            //print("Failed to create \(FileName).\(FileExtension)")
        }
    }

    @IBAction func PromptForAddFolderOrFile()
    {
        let Prompt = UIAlertController(title: "Create a new folder or file", message: "Enter a name and choose what you want to create", preferredStyle: UIAlertControllerStyle.Alert)
        Prompt.addTextFieldWithConfigurationHandler(nil)
        Prompt.addAction(UIAlertAction(title: "Create a new folder", style: UIAlertActionStyle.Default, handler:
            {
                (action : UIAlertAction) in

                if let Name = Prompt.textFields?.first?.text
                {
                    self.CreateFolderWithName(Name)
                }
            }
        ))
        Prompt.addAction(UIAlertAction(title: "Create a new file", style: UIAlertActionStyle.Default, handler:

            { (action : UIAlertAction) in
                if let FileName = Prompt.textFields?.first?.text
                {
                    self.CreateNewFileWithName(FileName)
                }
            }
        ))
        Prompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(Prompt, animated: false, completion: nil)
    }

    private func GetContentsOfDirectory(DirectoryPath : String)
    {
        let FileManager = NSFileManager()
        let AllowedExtensions = ["txt", "rtf", "pdf"]
        do
        {
            let ContentsOfCurrentDirectory = try FileManager.contentsOfDirectoryAtPath(DirectoryPath)
            for document in ContentsOfCurrentDirectory
            {
                let Pieces = document.componentsSeparatedByString(".")
                if Pieces.count >= 2 // a file
                {
                    let Extension = Pieces[Pieces.count-1]
                    if (AllowedExtensions.contains(Extension))
                    {
                        let CurrentFile = TextFile(FileName: document,
                                                   FullPath: DirectoryPath + "/" + document,
                                                   Location: DirectoryPath,
                                                   FileExtension: Extension)
                        self.FolderStack.last?.AddFolderElement(CurrentFile)
                    }
                }
                else // a folder
                {
                    let NewFolder = Folder(path: DirectoryPath + "/" + "\(document)", name: document)
                    self.FolderStack.last?.AddFolderElement(NewFolder)
                }
            }
        }
        catch
        {
            //print("ERROR LOADING DIRECTORY \(error)")
        }
    }

    func LoadDocuments(folder : Folder?)
    {
        if let f = folder
        {
            f.ResetContents()
            if let CurrentPath = folder?.Path
            {
                GetContentsOfDirectory(CurrentPath)
                self.ApplyFileSorting()
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
        self.UpdateBackButton()
    }

    private func RemoveItem(element : FolderElement)
    {
        let FileManager = NSFileManager()
        do
        {
            try FileManager.removeItemAtPath(element.Path)

            if let File = element as? TextFile
            {
                try FileManager.removeItemAtPath(ThumbnailName(File))
            }
        }
        catch
        {
            //print("Cannot delete \(element.Name) in \(element.Path), error file does not exist")
        }
    }

    //MARK: Folder Management

    func WentUpFolder()
    {
        if self.FolderStack.count > 1
        {
            //pop off the last item
            self.FolderStack.popLast()
            self.LoadDocuments(self.FolderStack.last)
            self.UpdateCurrentFolderTitle()
        }
    }

    func WentIntoFolder(folder : Folder)
    {
        if folder.Path != GetDocumentsDirectory()
        {
            self.FolderStack.append(folder)
        }
        self.FolderStack.last?.ResetContents()
        self.LoadDocuments(folder)
        self.tableView.reloadData()
        self.UpdateBackButton()
        self.UpdateCurrentFolderTitle()
    }

    func UpdateCurrentFolderTitle()
    {
        self.title = self.FolderStack.last?.Name
    }

    func ConfigureFolderStack()
    {
        let FirstFolder = Folder(path: GetDocumentsDirectory(), name: "Documents")
        self.FolderStack.append(FirstFolder)
    }

}


extension Array
{
    func ObjectAtIndex(i : Int) -> Element
    {
        if !(i >= 0 && i < self.count)
        {
            //print("Out of bounds for index \(i) for array \(self)")
        }

        return self[i]
    }
}

extension String
{

    func ContainsString(substr : String, caseSensitive : Bool) -> Bool
    {
        //print("case sensitive is \(caseSensitive)")
        var TempCopy = substr.characters.map({ String($0) })
        var NextCharacter : Character = "a"
        var Found = false

        if TempCopy.isEmpty { return false }

        if substr.characters.count > 0 && substr.characters.count < self.characters.count
        {
            for var i = 0; i < self.characters.count; i++
            {
                if TempCopy.isEmpty { return true }

                let current = self[self.startIndex.advancedBy(i)]
                //print("Current character is \(current)")
                NextCharacter = Character(TempCopy.removeAtIndex(TempCopy.startIndex))
                //print("Next character is \(NextCharacter)")

                var FoundCondition = "\(current)".lowercaseString == "\(NextCharacter)".lowercaseString

                if caseSensitive
                {
                    FoundCondition = "\(current)" == "\(NextCharacter)"
                }

                if FoundCondition
                {
                    Found = Found && true
                }
                else
                {
                    return false//TempCopy = substr.characters.map({ String($0) })
                }
                //print("Found is \(Found)")
                //print("Comparison string is \(TempCopy)")
            }
        }

        return Found
    }
}

func SortByAscendingName(left : FolderElement, right : FolderElement) -> Bool
{ return left.Name < right.Name }

func SortByDescendingName(left : FolderElement, right : FolderElement) -> Bool
{ return left.Name > right.Name }

func SortByAscendingSize(left : FolderElement, right : FolderElement) -> Bool
{ return left.Size < right.Size }

func SortByDescendingSize(left : FolderElement, right : FolderElement) -> Bool
{ return left.Size > right.Size }

func SortByAscendingCreationDate(left : FolderElement, right : FolderElement) -> Bool
{
    return AscendingDates(left.DateCreated, right: right.DateCreated)
}

func SortByDescendingCreationDate(left : FolderElement, right : FolderElement) -> Bool
{
    return DescendingDates(left.DateCreated, right: right.DateCreated)
}

func SortByAscendingModificationDate(left : FolderElement, right : FolderElement) -> Bool
{
    return AscendingDates(left.DateModified, right: right.DateModified)
}

func SortByDescendingModificationDate(left : FolderElement, right : FolderElement) -> Bool
{
    return DescendingDates(left.DateModified, right: right.DateModified)
}

func AscendingDates(left : NSDate, right : NSDate) -> Bool
{
    return left.compare(right) == NSComparisonResult.OrderedAscending
}

func DescendingDates(left : NSDate, right : NSDate) -> Bool
{
    return left.compare(right) == NSComparisonResult.OrderedDescending
}

func folderSize(folderPath:String) -> String{

    do
    {
        let filesArray:[String] = try NSFileManager.defaultManager() .subpathsOfDirectoryAtPath(folderPath) as [String]
        var fileSize:UInt = 0

        for fileName in filesArray{
            let filePath = NSURL(fileURLWithPath: folderPath).URLByAppendingPathComponent(fileName)
            let fileDictionary:NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath.path!)
            fileSize += UInt(fileDictionary.fileSize())
        }

        //1000 bytes is a KB
        //1000 kb is a MB
        //1000 mb is a GB

        var Final = Int(fileSize) / 1000

        var Units = "KB"

        if fileSize >= 1000000000
        {
            Units = "GB"
            Final = Int(fileSize) / 1000000000
        }
        else if fileSize >= 1000000
        {
            Units = "MB"
            Final = Int(fileSize) / 1000000
        }

        return Final.description + " \(Units)"
    }
    catch
    {

    }

    return ""

}












