//
//  Tree.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

import Foundation

public protocol TreeProtocol: Collection where Element == Self {
    associatedtype SubtreeCollection: RandomAccessCollection where
        SubtreeCollection.Element == Self
    var subtrees: SubtreeCollection { get }
}
public protocol MutableTreeProtocol: TreeProtocol where
SubtreeCollection: MutableCollection & RangeReplaceableCollection {
    var subtrees: SubtreeCollection { get set }
}
