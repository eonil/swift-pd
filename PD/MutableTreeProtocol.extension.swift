//
//  MutableTreeProtocol.extensions.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

public extension MutableTreeProtocol where
SubtreeCollection.Index == IndexPath.Element {
    /// - Note:
    ///     Container node is requird to exist.
    ///     Otherwise, this crashes.
    mutating func insert(_ n: Self, at idxp: IndexPath) {
        precondition(!idxp.isEmpty, "You cannot insert at root location.")
        precondition(contains(at: idxp.dropLast()), "You cannot insert where container node does not exist.")
        let i = idxp.last!
        self[idxp.dropLast()].subtrees.insert(n, at: i)
    }
    /// - Note:
    ///     A node must exist at the index.
    mutating func remove(at idxp: IndexPath) {
        precondition(contains(at: idxp), "You cannot remove node at wrong index.")
        let i = idxp.last!
        self[idxp.dropLast()].subtrees.remove(at: i)
    }
}
public extension MutableTreeProtocol where
SubtreeCollection.Index == IndexPath.Element {
    subscript(_ idxp: IndexPath) -> Element {
        get {
            switch idxp.count {
            case 0:
                return self
            default:
                let i = idxp.first!
                let p = idxp.dropFirst()
                return subtrees[i][p]
            }
        }
        set(v) {
            switch idxp.count {
            case 0:
                self = v
            default:
                let i = idxp.first!
                let p = idxp.dropFirst()
                subtrees[i][p] = v
            }
        }
    }
}
