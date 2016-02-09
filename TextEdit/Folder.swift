//
//  Folder.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/22/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

class Folder : FolderElement
{
    private var _contents = [FolderElement]()

    var Contents : [FolderElement]
    {
        get { return self._contents }
    }

    override init()
    {
        self._contents = [FolderElement]()
    }

    init(path : String, contents : [FolderElement])
    {
        self._contents = contents
    }

    init(path : String, name : String)
    {
        super.init()
        self._path = path
        self._contents = [FolderElement]()
        self._name = name
    }

    func SortContents(criteria : (FolderElement, FolderElement) -> Bool)
    {
        self._contents.sortInPlace(criteria)
    }

    func RemoveFileAtIndex( i : Int)
    {
        self._contents.removeAtIndex(i)
    }

    func ResetContents()
    {
        self._contents = [FolderElement]()
    }

    func AddFolderElement(element : FolderElement) { self._contents.append(element) }
}