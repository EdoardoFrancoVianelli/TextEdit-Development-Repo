//
//  DocumentEditorViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/17/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

class DocumentEditorViewController : UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate
{
    let FormattingIdentifier = "FormattingSegue"

    var CurrentFile = TextFile(FileName: "", FullPath: "", Location: "", FileExtension: "")

    @IBOutlet weak var FileDisplayer: UITextView!

    var CreatingFile = false

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.UpdateThumbnail()
        self.Save()
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.FileDisplayer.layer.borderWidth = 1

        self.ConfigurePinchToZoom()

        if !CreatingFile
        {
            self.LoadContentsOfCurrentFile()
        }

        self.FileDisplayer.delegate = self
        self.InitializeUpperRightControls()
    }

    func ThumbnailName(file : TextFile) -> String
    {
        return file.Path + "-Thumbnail.jpg"
    }

    func DoneEditing()
    {
        self.FileDisplayer.resignFirstResponder()
        self.Save()
    }

    func DisplayShare()
    {
        let ShareWindow = UIActivityViewController(activityItems: [FileDisplayer.text], applicationActivities: nil)
        self.presentViewController(ShareWindow, animated: false, completion: nil)
    }

    private func LoadContentsOfCurrentFile()
    {
        //is it a txt or an RTF?

        if self.CurrentFile.Extension == "txt"
        {
            self.OpenTXTPath(self.CurrentFile.Path)
        }
        else if self.CurrentFile.Extension == "rtf"
        {
            //print("recognized rtf")
            self.OpenRTFFile(self.CurrentFile.Path)
        }
    }



    func SetAttributeForSelectedText(name : String, value : AnyObject)
    {
        let FormattedText : NSMutableAttributedString = NSMutableAttributedString(attributedString: self.FileDisplayer.attributedText)
        FormattedText.addAttribute(name, value: value, range: self.FileDisplayer.selectedRange)
        self.FileDisplayer.attributedText = FormattedText
    }

    func SetSelectedBold()
    {
        SetAttributeForSelectedText(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14))
    }

    func SetSelectedItalics()
    {
        SetAttributeForSelectedText(NSFontAttributeName, value: UIFont.italicSystemFontOfSize(14))
    }

    func SetSelectedUnderline()
    {
        SetAttributeForSelectedText(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue)
    }

    func DisplayDone()
    {
        self.FileDisplayer.resignFirstResponder()
        self.FileDisplayer.attributedText = NSAttributedString(attributedString: self.FileDisplayer.attributedText)
    }

    func InitializeUpperRightControls()
    {
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem]()
        let UpperRightOptions = ["Formatting", "Share", "Done"]
        for UpperRightOption in UpperRightOptions
        {
            if !(UpperRightOption == "Formatting" && CurrentFile.Extension == "txt")
            {
                let CurrentAction : Selector = Selector.init("Display" + UpperRightOption)
                let NewButton = UIBarButtonItem(title: UpperRightOption,
                                                style: UIBarButtonItemStyle.Plain,
                                                target: self,
                                                action: CurrentAction)
                self.navigationItem.rightBarButtonItems?.append(NewButton)
            }
        }
    }

    func DisplayFormatting()
    {
        if self.CurrentFile.Extension != "txt"
        {
            if let CurrentSelected = self.FileDisplayer.selectedRange.toRange()
            {
                if CurrentSelected.startIndex == CurrentSelected.endIndex
                {
                    let NothingSelected = UIAlertController(title: "Nothing is selected", message: "Please select a portion of text to format", preferredStyle: UIAlertControllerStyle.Alert)
                    NothingSelected.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(NothingSelected, animated: true, completion: nil)
                }
                else
                {
                    self.performSegueWithIdentifier(FormattingIdentifier, sender: self)
                }
            }
        }
    }

    private func Save()
    {
        if self.CurrentFile.Extension == "txt"
        {
            self.SaveTXTFile()
        }
        else if self.CurrentFile.Extension == "rtf"
        {
            self.SaveRTFFile()
        }
    }

    func SaveRTFFile()
    {
//        let file_data = NSKeyedArchiver.archivedDataWithRootObject(self.FileDisplayer.attributedText)
//        file_data.writeToFile(self.CurrentFile.Path + "/" + self.CurrentFile.FullFilename, atomically: true)
//
        let Attributes = [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType]
        do
        {
            let Wrapper = try self.FileDisplayer.attributedText.fileWrapperFromRange(NSRange(location: 0, length: self.FileDisplayer.attributedText.length), documentAttributes: Attributes)
            let string_path = self.CurrentFile.Path
            print("Path to save is \(string_path)")
            let URLForPath = NSURL(fileURLWithPath: string_path)
            try Wrapper.writeToURL(URLForPath, options: NSFileWrapperWritingOptions.Atomic, originalContentsURL: nil)
        }
        catch
        {
            print("Error on line 180")
            print(error)
        }
    }

    func SaveTXTFile()
    {
        //print("Attempting to save \(self.CurrentFile.Path)")
        do
        {
            try self.FileDisplayer.attributedText.string.writeToFile(CurrentFile.Path, atomically: true, encoding: NSUTF32StringEncoding)
        }
        catch
        {
            print("Error writing to \(self.CurrentFile.Path)")
        }
    }



    private func GetContentsOfFileWithPath(path : String) -> String?
    {
        do
        {
            let contents = try String(contentsOfFile: path, encoding: NSUTF32StringEncoding)
            return String(contents)
        }
        catch
        {
            print("Error on line 209")
            print(error)
            return nil
        }
    }

    func textViewDidEndEditing(textView: UITextView)
    {
        self.Save()
    }

    func UpdateThumbnail()
    {
        //check if the thumbnail exists
        let ThumbnailFilePath = ThumbnailName(self.CurrentFile)

        do { try NSFileManager.defaultManager().removeItemAtPath(ThumbnailFilePath) }
        catch
        {
            print("Error on line 228")
            print(error)
        }

        let ImageToSave = GetCurrentIcon(self.view)
        let JPGRepresentation = UIImageJPEGRepresentation(ImageToSave, 1.0)
        JPGRepresentation?.writeToFile(ThumbnailFilePath, atomically: true)
    }

    func GetCurrentIcon(view : UIView) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image
    }

    func textViewDidChange(textView: UITextView)
    {

    }

    func OpenTXTPath(path : String)
    {
        if let Contents = self.GetContentsOfFileWithPath(self.CurrentFile.Path)
        {
            self.FileDisplayer.attributedText = NSAttributedString(string: Contents)
        }
        else
        {
            //print("Error reading \(CurrentFile.Path)")
        }
    }

    func ChangeAttributedStringForRange(string : NSAttributedString, range : NSRange)
    {
        let CurrentString = NSMutableAttributedString(attributedString: self.FileDisplayer.attributedText)
        CurrentString.replaceCharactersInRange(range, withAttributedString: string)
        self.FileDisplayer.attributedText = CurrentString
    }

    func OpenRTFFile(path : String)
    {
        //print("Paths is \(path)")
        if let DocumentData = NSData(contentsOfFile: path)
        {
            let Options = [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType]
            do
            {
                let AttributedContents = try NSAttributedString(data: DocumentData, options: Options, documentAttributes: nil)
                self.FileDisplayer.attributedText = AttributedContents
            }
            catch
            {
                print("Error on line 310")
                print(error)
            }
        }
        else
        {
            //print("\(path) does not exist")
        }
    }

    //MARK: Zoom Gesture stuff


    func ConfigurePinchToZoom()
    {
        let PinchGesture = UIPinchGestureRecognizer(target: self, action: "HandleZoom:")
        self.FileDisplayer.addGestureRecognizer(PinchGesture)
    }

    func HandleZoom(sender : UIPinchGestureRecognizer)
    {
        let MaximumFontSize : CGFloat = 40
        let MinimumFontSize : CGFloat = 10

        if let CurrentFont = self.FileDisplayer.font
        {
            let NewSize = CurrentFont.pointSize * sender.scale
            if NewSize >= MinimumFontSize && NewSize <= MaximumFontSize
            {
                self.FileDisplayer.font = UIFont(name: CurrentFont.familyName, size: NewSize)
            }
            else if NewSize < MinimumFontSize
            {
                self.FileDisplayer.font = UIFont(name: CurrentFont.familyName, size: MinimumFontSize)
            }
            else
            {
                self.FileDisplayer.font = UIFont(name: CurrentFont.familyName, size: MaximumFontSize)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        self.FileDisplayer.resignFirstResponder()
        if segue.identifier == FormattingIdentifier
        {
            if let Destination = (segue.destinationViewController as? FormattingViewController)
            {
                //Destination.popoverPresentationController.
                Destination.modalPresentationStyle = UIModalPresentationStyle.Popover
                Destination.popoverPresentationController!.delegate = self
                let CurrentString = NSMutableAttributedString(attributedString: self.FileDisplayer.attributedText).attributedSubstringFromRange(self.FileDisplayer.selectedRange)
                Destination.CurrentFormattedString = NSMutableAttributedString(attributedString: CurrentString)
                Destination.CurrentRange = self.FileDisplayer.selectedRange
            }
        }
    }
}







