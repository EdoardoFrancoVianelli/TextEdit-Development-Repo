//
//  CustomSegmentedControl.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 1/10/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation
import UIKit

class CustomSegmentedControl : UIView
{

    private var options = [UIButton]()

    init(titles : [String], Origin : CGPoint)
    {
        super.init(frame: CGRect.zero)

        self.frame.origin = Origin

        var Width : CGFloat = 0.0
        let Height : CGFloat = 40.0

        for title in titles
        {
            let CurrentButton = UIButton()
            CurrentButton.frame.size.height = Height
            CurrentButton.frame.size.width = CGFloat(10 * title.characters.count)
            CurrentButton.frame.origin.x = Width
            CurrentButton.frame.origin.y = 0.0
            Width += CurrentButton.frame.size.width
            CurrentButton.setTitle(title, forState: UIControlState.Normal)

            CurrentButton.setColorForState(UIColor.blueColor(), state: UIControlState.Highlighted)
            

            self.addSubview(CurrentButton)
        }

        self.layer.cornerRadius = 6.0
        self.layer.borderColor = UIColor.blueColor().CGColor
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}

extension UIButton
{
    func setColorForState(newColor : UIColor, state : UIControlState)
    {
        let colorView = UIView(frame: self.frame)
        colorView.backgroundColor = newColor
        UIGraphicsBeginImageContext(colorView.bounds.size)
        colorView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, forState: state)
    }
}
