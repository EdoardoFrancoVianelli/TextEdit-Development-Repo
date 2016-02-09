//
//  FolderElement.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/22/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class FolderElement : CustomStringConvertible
{
    internal var _name = ""
    internal var _size : UInt64 = 0
    internal var _date_created = NSDate()
    internal var _date_modified = NSDate()

    internal var _path = ""

    var Path : String
        {
        get { return self._path }
    }

    var DateCreated : NSDate
    {
        get { return self._date_created }
        set { self._date_created = newValue }
    }

    var DateModified : NSDate
    {
        get { return self._date_modified }
        set { self._date_modified = newValue }
    }

    var Name : String
    {
        get
        {
            return self._name
        }
    }

    var Size : UInt64
    {
        get
        {
            return self._size
        }
    }

    var description : String
    {
        return self.Name
    }
}