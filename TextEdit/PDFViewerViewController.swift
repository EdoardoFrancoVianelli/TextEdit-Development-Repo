//
//  PDFViewerViewController.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 12/4/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import UIKit

class PDFViewerViewController: UIViewController {

    @IBOutlet weak var MainPDFViewer: UIWebView!
    let CurrentFile = PDFFile(FileName: "", FullPath: "", Location: "", FileExtension: "")

    func LoadCurrentPDF()
    {
        if let URL = NSURL(string: CurrentFile.Path)
        {
            self.MainPDFViewer.loadRequest(NSURLRequest(URL: URL))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.LoadCurrentPDF()
        // Do any additional setup after loading the view.
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
