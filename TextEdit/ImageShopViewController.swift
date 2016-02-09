//
//  ImageShopViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/21/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class ImageShopViewController: UIViewController {

    var TextDisplayer = UILabel()

    var ResultView = UIView()

    var IconTextField = UITextField(frame: CGRect.zero)

    func AddTapToSave()
    {
        let TapGesture = UITapGestureRecognizer(target: self, action: "SaveIcon")
        TapGesture.numberOfTapsRequired = 1
        self.ResultView.addGestureRecognizer(TapGesture)
    }

    func SaveIcon()
    {
        UIImageWriteToSavedPhotosAlbum(self.GetCurrentIcon(), nil, nil, nil)
    }

    func GetCurrentIcon() -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.ResultView.frame.size, false, 0.0)
        self.ResultView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image
    }

    func SetImageText(sender: UITextField)
    {
        self.TextDisplayer.transform = CGAffineTransformRotate(self.TextDisplayer.transform, CGFloat(-M_PI_4))
        self.TextDisplayer.font = UIFont.boldSystemFontOfSize(35)
        var NumberOfLines = 0

        if let Text = sender.text
        {
            if Text.characters.count <= 10
            {
                NumberOfLines = 1
            }
            else if Text.characters.count <= 20
            {
                NumberOfLines = 2
            }
            else if Text.characters.count <= 30
            {
                NumberOfLines = 3
            }
            if NumberOfLines > 0
            {
                self.TextDisplayer.text = Text
                self.TextDisplayer.numberOfLines = NumberOfLines
            }
            else
            {
                //print("Not accepted")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ResultView = UIView(frame: CGRect.zero)
        self.SizeIconViewer()
        self.AddTextField()
        self.ConfigureTextDisplayer()
        self.AddTapToSave()
        // Do any additional setup after loading the view.
    }

    func ConfigureTextDisplayer()
    {
        self.TextDisplayer = UILabel(frame: CGRect.zero)
        self.TextDisplayer.frame.size = self.ResultView.frame.size
        self.TextDisplayer.textAlignment = NSTextAlignment.Center
        self.ResultView.addSubview(self.TextDisplayer)
    }

    func AddTextField()
    {
        self.IconTextField.frame.size.height = 40
        self.IconTextField.frame.size.width = self.ResultView.frame.size.width
        self.IconTextField.frame.origin.x = self.ResultView.frame.origin.x
        self.IconTextField.frame.origin.y = self.ResultView.frame.origin.y + self.ResultView.frame.size.height + 10
        self.IconTextField.layer.borderWidth = 1.0
        self.IconTextField.addTarget(self, action: "SetImageText:", forControlEvents: UIControlEvents.EditingDidEndOnExit)
        self.view.addSubview(self.IconTextField)
    }

    func SizeIconViewer()
    {
        let IconPreviewSize = CGSize(width: 200, height: 200)
        self.ResultView.frame.size = IconPreviewSize
        self.ResultView.frame.origin.x = UIScreen.mainScreen().bounds.size.width / 2 - self.ResultView.frame.size.width / 2
        self.ResultView.frame.origin.y = UIScreen.mainScreen().bounds.size.height / 2 - self.ResultView.frame.size.height / 2
        self.ResultView.layer.borderWidth = 1.0
        self.view.addSubview(self.ResultView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
