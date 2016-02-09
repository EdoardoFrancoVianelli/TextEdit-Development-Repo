//
//  TextFile.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/17/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class TextFile : FolderElement
{
    private var FileAttributes : NSDictionary?
    private var _location = ""
    private var _wordCount = 0
    private var _extension = ""

    var Location : String { get { return self.Location } }

    var FileSize : UInt64 { get { return self._size } }

    var FullFilename : String { get { return self.Name + "." + self.Extension } }

    var Extension : String
    {
        get
        {
            return self._extension
        }
    }

    var WordCount : Int
    {
        get { return self._wordCount }
        set { print("Increment is \(newValue)");self._wordCount += newValue }
    }

    var FileSizeDescriptor : String
    {
        let count = FileSize.description.characters.count

        if count >= 7
        {
            return (Double(FileSize) / 1000000.0).description + " GB"
        }
        else if count >= 4
        {
            return (Double(FileSize) / 1000.0).description + " KB"
        }
        else
        {
            return FileSize.description + " B"
        }
    }

    func GetAttributes() -> Dictionary<String, String>
    {
        var attr = Dictionary<String, String>()

        if let attributes = self.FileAttributes
        {
            for item in attributes
            {
                attr[item.key.description] = item.value.description
            }
        }

        return attr
    }

    init(FileName : String, FullPath : String, Location : String, FileExtension : String)
    {
        //NSFileCreationDate
        //NSFileModificationDate
        super.init()
        self._name = FileName
        self._path = FullPath
        self._location = Location
        self._extension = FileExtension
        do
        {
            self.FileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(FullPath)
            if let filesize = self.FileAttributes?.fileSize()
            {
                self._size = filesize
            }

            

            if let creation = self.FileAttributes?.fileCreationDate()
            {
                self._date_created = creation
            }
            if let modification = self.FileAttributes?.fileModificationDate()
            {
                self._date_modified = modification
            }
        }
        catch
        {
            //print("Full path is \(FullPath)")
            //print("This is where the error happens")
            //print(error)
        }
    }

}