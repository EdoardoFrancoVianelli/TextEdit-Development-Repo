//
//  Miscellaneous Useful Code.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 11/26/15.
//  Copyright © 2015 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

func GetDocumentsDirectory() -> String
{
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
    //print(paths)
    return paths.first!
}