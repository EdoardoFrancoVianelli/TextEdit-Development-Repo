//
//  Trie.swift
//  TextEdit
//
//  Created by Edoardo Franco Vianelli on 1/29/16.
//  Copyright © 2016 Edoardo Franco Vianelli. All rights reserved.
//

import Foundation

final class Trie
{
    private var _root : TrieNode?

    init()
    {
        self._root = TrieNode()
        self._root?.Item = "\0"
    }

    func WordsStartingWith(str : String) -> [String]
    {
        var _ = [String]()

        var current_node = self._root

        for current in str.characters.enumerate()
        {
            if let found_index = current_node?.ChildrenHaveCharacter(current.element)
            {
                current_node = current_node?.ChildAtIndex(found_index)
            }else { return [String]() }
        }

        var nodes_to_traverse = [TrieNode]()

        if let count = current_node?.ChildCount
        {
            for var i = 0; i < count; i++
            {
                if let node = current_node?.ChildAtIndex(i)
                {
                    nodes_to_traverse.append(node)
                }
            }
        }

        //a nodestack in which each level is an array of nodes to traverse

        var node_stack = [[TrieNode]]()
        node_stack.append(nodes_to_traverse)

        return [String]()
    }

    func AddString(str : String)
    {
        if self._root == nil
        {
            self._root = TrieNode()
            self._root?.Item = "\0"
        }
        else
        {
            var current_node = self._root
            for (i,current_character) in str.characters.enumerate()
            {
                if let found_index = current_node?.ChildrenHaveCharacter(current_character)
                {
                    current_node = current_node?.ChildAtIndex(found_index)
                    current_node?.end = false
                }
                else
                {
                    let new_node = TrieNode()
                    new_node.Item = current_character
                    current_node?.AddChild(new_node)
                    current_node = new_node
                    if i == str.characters.count - 1
                    {
                        new_node.end = true
                    }
                }
            }
        }
    }
}