//
//  TrieNode.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 1/29/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

final class TrieNode
{
    private var _c : Character = "a"
    private var _children = [TrieNode]()
    var ChildCount : Int { get { return _children.count } }

    var end = false

    init()
    {
        _c = "a"
        _children = [TrieNode]()
    }

    var Item : Character
    {
        set { self._c = newValue }
        get { return self._c }
    }

    func AddChild(child : TrieNode) { self._children.append(child) }

    func ChildAtIndex(i : Int) -> TrieNode { return self._children[i] }

    func RemoveChildAtIndex(i : Int) -> TrieNode { return self._children.removeAtIndex(i) }

    func ChildrenHaveCharacter(c : Character) -> Int?
    {
        for (i,child) in self._children.enumerate()
        {
            if child._c == c { return i }
        }

        return nil
    }
}