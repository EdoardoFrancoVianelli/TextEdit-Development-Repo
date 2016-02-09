//
//  PDFFile.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 12/4/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class PDFFile : FolderElement
{

    init(FileName : String, FullPath : String, Location : String, FileExtension : String)
    {
        super.init()
        super._name = FileName
        super._path = FullPath
    }

}