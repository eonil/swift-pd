//
//  TreeProtocol.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

import Foundation

public protocol TreeProtocol {
    associatedtype SubtreeCollection: RandomAccessCollection where SubtreeCollection.Element == Self
    var subtrees: SubtreeCollection { get }
}
public protocol MutableTreeProtocol: TreeProtocol where SubtreeCollection: MutableCollection & RangeReplaceableCollection {
    var subtrees: SubtreeCollection { get set }
}










public extension TreeProtocol where SubtreeCollection.Index == Int {
    subscript(_ idxp: IndexPath) -> Self {
        switch idxp.count {
        case 0:
            return self
        default:
            let i = idxp.first!
            let p = idxp.dropFirst()
            return subtrees[i][p]
        }
    }
    func contains(at idxp: IndexPath) -> Bool {
        switch idxp.count {
        case 0:
            return true
        default:
            let i = idxp.first!
            let p = idxp.dropFirst()
            return subtrees[i].contains(at: p)
        }
    }
}

public extension TreeProtocol where SubtreeCollection.Index == Int {
    ///
    /// Make an iterator which iterates index-paths to all node in tree in DFS(depth first search) manner.
    ///
    /// - worst time complexity:    O(n)
    /// - worst space complexity:   O(n)
    ///
    /// - Parameter isIncluded:
    ///     Filters subtree to iterate.
    ///     If this function returns `false`, whole subtree will be skipped
    ///     from iteration.
    ///
    func makeDFSIterator(isIncluded: @escaping (IndexPath,Self) -> Bool = { _,_ in true }) -> AnyIterator<(IndexPath,Self)> {
        typealias Pair = (location: IndexPath, content: Self)
        var stack = [Pair]()
        stack.append((IndexPath(), self))
        return AnyIterator { () -> Pair? in
            guard !stack.isEmpty else { return nil }
            let (idxp,node) = stack.removeLast()
            for i in node.subtrees.indices.lazy.reversed() {
                let idxp1 = idxp.appending(i)
                let node1 = node.subtrees[i]
                if isIncluded(idxp1,node1) {
                    stack.append((idxp1,node1))
                }
            }
            return (idxp,node)
        }
    }
    ///
    /// Make an iterator which iterates index-paths to all node in tree in DFS(depth first search) manner.
    ///
    /// - worst time complexity:    O(n)
    /// - worst space complexity:   O(n)
    ///
    /// - Parameter isIncluded:
    ///     Filters subtree to iterate.
    ///     If this function returns `false`, whole subtree will be skipped
    ///     from iteration.
    ///
    func makeDFSIndexPathIterator(isIncluded: @escaping (IndexPath) -> Bool = { _ in true }) -> AnyIterator<IndexPath> {
        let it = makeDFSIterator()
        return AnyIterator { () -> IndexPath? in
            return it.next()?.0
        }
    }
}











public extension MutableTreeProtocol where SubtreeCollection: RangeReplaceableCollection, SubtreeCollection.Index == IndexPath.Element {
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
public extension MutableTreeProtocol where SubtreeCollection.Index == IndexPath.Element {
    subscript(_ idxp: IndexPath) -> Self {
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
        set {
            switch idxp.count {
            case 0:
                self = newValue
            default:
                let i = idxp.first!
                let p = idxp.dropFirst()
                subtrees[i][p] = newValue
            }
        }
    }
}
