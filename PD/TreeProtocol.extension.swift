//
//  TreeProtocol.extension.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

extension TreeProtocol where Index == IndexPath {

}
/// Tree will get automatic collection support if subtree has `Int` index.
/// In this automatic support, index type is `IndexPath`, starting index is `[]`(root),
/// and ending index is `[subtrees.count]`(next of last child).
/// Iteration will be done in Depth-First-Search order.
extension TreeProtocol where SubtreeCollection.Index == IndexPath.Element {
    public var startIndex: IndexPath {
        return []
    }
    public var endIndex: IndexPath {
        return [subtrees.count]
    }
    public func index(after i: IndexPath) -> IndexPath {
        return i.nextDFS(on: self) ?? endIndex
    }
}

public extension TreeProtocol where SubtreeCollection.Index == IndexPath.Element {
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

public extension TreeProtocol where SubtreeCollection.Index == IndexPath.Element {
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

private extension IndexPath {
    func up() -> IndexPath? {
        switch count {
        case 0:
            // Root.
            return nil
        default:
            return dropLast()
        }
    }
    func down<Tree>(at i: Int, on source: Tree) -> IndexPath? where Tree: TreeProtocol, Tree.SubtreeCollection.Index == Element {
        return i < source[self].subtrees.count ? nil : appending(i)
    }
    func right<Tree>(on source: Tree) -> IndexPath? where Tree: TreeProtocol, Tree.SubtreeCollection.Index == Element {
        switch count {
        case 0:
            // Root. No right sibling.
            return nil
        default:
            let i = last! + 1
            return up()?.down(at: i, on: source)
        }
    }
    func nextDFS<Tree>(on source: Tree) -> IndexPath? where Tree: TreeProtocol, Tree.SubtreeCollection.Index == Element {
        return down(at: 0, on: source)
            ?? right(on: source)
            ?? { () -> IndexPath? in
                var x = self as IndexPath?
                while x != nil {
                    if let z = x?.up()?.right(on: source) {
                        return z
                    }
                    x = x?.up()
                }
                return nil
            }()
    }
}
