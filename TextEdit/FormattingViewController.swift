//
//  FormattingViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/25/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

protocol FormattingDelegate
{
    func DidFinishFormattingString(string : NSAttributedString)
}

class FormattingViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var formattingOptionsScroller: UIScrollView!
    var CurrentRange = NSRange(location: 0, length: 0)

    var SelectedRow = 0

    var OldStepperValue = 0.0

    @IBOutlet weak var CurrentFormattingPreview: UITextView!

    var CurrentFormattedString : NSMutableAttributedString = NSMutableAttributedString()

    let FormattingSelectionSegueID = "FormattingSelectionViewControllerSegue"

    var FontChoices = [NSAttributedString]()
    var ColorChoices = [NSAttributedString]()

    var SettingResult : NSAttributedString?

    var CurrentString : NSMutableAttributedString
    {
        get
        {
            return CurrentFormattedString
        }
        set
        {
            self.CurrentFormattingPreview.attributedText = newValue
        }
    }

    @IBAction func DoneEditing(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    @IBAction func ChangeFont()
    {
        self.FontChoices = [NSAttributedString]()

        let AllFamilyNameFonts = UIFont.familyNames()

        for FamilyNameFont in AllFamilyNameFonts
        {
            let FontNames = UIFont.fontNamesForFamilyName(FamilyNameFont)
            for FontName in FontNames
            {
                if let CurrentFont = UIFont(name: FontName, size: 16.0)
                {
                    self.FontChoices.append(NSAttributedString(string: FontName, attributes: [NSFontAttributeName : CurrentFont]))
                }
            }
        }

        self.performSegueWithIdentifier(FormattingSelectionSegueID, sender: "FontChange")
    }

    @IBAction func ChangedFontsize(sender: UIStepper)
    {
        var increased = false

        if sender.value > OldStepperValue { increased = true }

        //print("New value is \(sender.value)")
        //print("Old value is \(OldStepperValue)")

        let NewString = self.CurrentString
        NewString.enumerateAttribute(NSFontAttributeName, inRange: NSRange(location: 0, length: NewString.length), options: NSAttributedStringEnumerationOptions.Reverse, usingBlock: {

            (attribute : AnyObject?, range : NSRange, _) in

            if let font = attribute as? UIFont
            {
                var NewSize : CGFloat = 0.0
                if increased
                {
                    NewSize = CGFloat(sender.value) + font.pointSize
                    if NewSize > 100
                    {
                        NewSize = 100
                    }
                }
                else
                {
                    NewSize = font.pointSize - CGFloat(sender.value)
                    if NewSize < 10
                    {
                        NewSize = 10
                    }
                }

                let NewFont = UIFont(descriptor: font.fontDescriptor(), size: CGFloat(NewSize))
                NewString.addAttribute(NSFontAttributeName, value: NewFont, range: range)
            }


        })
        CurrentString = NewString
        OldStepperValue = sender.value
    }

    @IBAction func ChangeColor()
    {
        self.ColorChoices = [NSAttributedString]()
        let AllColors = ["Black" : UIColor.blackColor(), "Blue" : UIColor.blueColor(),
            "Brown" : UIColor.brownColor(),
            "Cyan": UIColor.cyanColor(),  "Dark Gray" : UIColor.darkGrayColor(),
            "Dark Text" : UIColor.darkTextColor(), "Gray" : UIColor.grayColor(), "Green" : UIColor.greenColor(), "Lighter Gray" : UIColor.groupTableViewBackgroundColor(), "Light Gray" : UIColor.lightGrayColor(), "Magenta Color": UIColor.magentaColor(),"Orange Color" : UIColor.orangeColor(), "Purple Color" : UIColor.purpleColor(), "Red" : UIColor.redColor(), "Yellow" : UIColor.yellowColor()]

        for (ColorName, color) in AllColors
        {
            self.ColorChoices.append(NSAttributedString(string: ColorName, attributes: [NSForegroundColorAttributeName : color]))
            //print(ColorName)
        }

        self.performSegueWithIdentifier(FormattingSelectionSegueID, sender: "ColorChange")
    }

    func ItalicizedForFont(startFont : UIFont) -> UIFont
    {
        let Descriptor = startFont.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitItalic)
        return UIFont(descriptor: Descriptor, size: startFont.pointSize)
    }

    func BoldFontForFont(startFont : UIFont) -> UIFont
    {
        let Descriptor = startFont.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
        return UIFont(descriptor: Descriptor, size: startFont.pointSize)
    }

    @IBAction func ChangeBasicTextFeatures(sender: UISegmentedControl)
    {
        let NewString = self.CurrentString

        if sender.selectedSegmentIndex < 2
        {

            NewString.enumerateAttribute(NSFontAttributeName, inRange: NSRange(location: 0, length: NewString.length), options: NSAttributedStringEnumerationOptions.Reverse, usingBlock: {

                (attribute : AnyObject?, range : NSRange, _) in

                if let CurrentFont = attribute as? UIFont
                {
                    if sender.selectedSegmentIndex == 0
                    {
                        NewString.addAttribute(NSFontAttributeName, value: self.BoldFontForFont(CurrentFont), range: range)
                    }
                    else if sender.selectedSegmentIndex == 1
                    {
                        NewString.addAttribute(NSFontAttributeName, value: self.ItalicizedForFont(CurrentFont), range: range)
                    }
                }

            })
        }
        else if sender.selectedSegmentIndex == 2
        {
            //if not all underlined, underline all
            //else remove underline

            var allUnderlined = true

            NewString.enumerateAttributesInRange(NSRange(0..<NewString.length), options: []) { (attributes, range, _) -> Void in
                if let underline = attributes[NSUnderlineStyleAttributeName] as? NSUnderlineStyle
                {
                    if underline.rawValue == NSUnderlineStyle.StyleNone.rawValue
                    {
                        allUnderlined = false
                    }
                }
                else { allUnderlined = false }
            }

            //print("All underlined is \(allUnderlined)")

            if !allUnderlined
            {
                NewString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: 0, length: NewString.length))
            }
            else
            {
                NewString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleNone.rawValue, range: NSRange(location: 0, length: NewString.length))
            }

        }
        else if sender.selectedSegmentIndex == 3
        {
            NewString.addAttribute(NSStrikethroughStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: 0, length: NewString.length))
        }

        self.CurrentString = NewString

    }

    @IBAction func ChangeAlignment(sender: UISegmentedControl)
    {
        let Alignments = [NSTextAlignment.Left, NSTextAlignment.Center, NSTextAlignment.Right]
        let ParagraphStyle = NSMutableParagraphStyle()
        ParagraphStyle.alignment = Alignments[sender.selectedSegmentIndex]
        let StringToEdit = self.CurrentString
        StringToEdit.addAttribute(NSParagraphStyleAttributeName, value: ParagraphStyle, range: NSRange(location: 0, length: self.CurrentFormattedString.length))
        self.CurrentString = StringToEdit
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let res = SettingResult{
            self.CurrentString = NSMutableAttributedString(attributedString: res)
        }
        SettingResult = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.formattingOptionsScroller.contentInset = UIEdgeInsetsMake(0,0,self.view.frame.size.height,0)
        self.CurrentString = self.CurrentFormattedString

    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let Root = self.view.window?.rootViewController
        {
            if let Editor = Root.childViewControllers[1] as? DocumentEditorViewController
            {
                Editor.ChangeAttributedStringForRange(self.CurrentString, range: self.CurrentRange)
            }
        }
    }

    func ProcessReturn(returnValue : NSAttributedString)
    {
        //print("Font name is \(returnValue)")

        let before = self.CurrentString
        let FullRange = NSRange(location: 0, length: CurrentString.length)

        if let ChosenFont = UIFont(name: returnValue.string, size: 13.0)
        {
            before.addAttribute(NSFontAttributeName, value: ChosenFont, range: FullRange)
        }
        //determine the color to set
        //get the color attribute 
        if let Color = returnValue.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: NSRangePointer()) as? UIColor
        {
            before.addAttribute(NSForegroundColorAttributeName, value: Color, range: FullRange)
        }

        self.CurrentString = before
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.formattingOptionsScroller.frame = self.view.bounds
        self.formattingOptionsScroller.contentSize.height = self.view.frame.size.height
        self.formattingOptionsScroller.contentSize.width = 0
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let Description = sender?.description
        {
            if let DestinationViewController = segue.destinationViewController as? FormattingSelectionTableViewController
            {


                DestinationViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
                DestinationViewController.popoverPresentationController!.delegate = self
                //print(Description)
                if Description == "FontChange"
                {
                    DestinationViewController.SetContentsSelection(self.FontChoices)
                    DestinationViewController.ID = TaskIdentifier.FontEditing
                }
                else if Description == "ColorChange"
                {
                    DestinationViewController.SetContentsSelection(self.ColorChoices)
                    DestinationViewController.ID = TaskIdentifier.ColorEditing
                }
                DestinationViewController.SourceString = self.CurrentString
            }
        }
    }





}
