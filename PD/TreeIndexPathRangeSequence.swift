//
//  TreeIndexPathRangeSequence.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/19.
//

import Foundation

/// This includes descendants.
struct TreeIndexPathRangeDFSSequence<Tree>: Sequence where
Tree: TreeProtocol,
Tree.SubtreeCollection.Index == IndexPath.Element {
    var source: Tree
    var range: Range<IndexPath>
    init(source s: Tree, range r: Range<IndexPath>) {
        source = s
        range = r
    }
    func makeIterator() -> TreeIndexPathRangeDFSIterator<Tree> {
        return TreeIndexPathRangeDFSIterator(with: range, on: source)
    }
}
struct TreeIndexPathRangeDFSIterator<Tree>: IteratorProtocol where
Tree: TreeProtocol,
Tree.SubtreeCollection.Index == IndexPath.Element {
    var source: Tree
    var range: Range<IndexPath>
    var offset = 0
    var pointee: IndexPath?
    init(with r: Range<IndexPath>, on s: Tree) {
        source = s
        range = r
        pointee = r.lowerBound
    }
    var canStep: Bool {
        return pointee != range.upperBound
    }
    mutating func step() {
        precondition(canStep)
        offset += 1
        pointee = pointee?.nextDFS(on: source)
    }
    mutating func next() -> IndexPath? {
        guard canStep else { return nil }
        let x = pointee
        step()
        return x
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
