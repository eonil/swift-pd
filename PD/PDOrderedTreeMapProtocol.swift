//
//  PDOrderedTreeMapProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDOrderedTreeMapProtocol: PDSnapshotProtocol
where Selection == PDOrderedTreeMapSelection<Key> {
    associatedtype Key: Comparable
    associatedtype Value
    typealias Element = (key: Key, value: Value)


    init(_ root: Element)
    subscript(_ key: Key) -> Value { get set }
    mutating func insert(_ element: Element, at i: Int, in key: Key)
    @discardableResult
    mutating func remove(at i: Int, in key: Key) -> Element
}

extension PDOrderedTreeMap: PDOrderedTreeMapProtocol {}
public extension PDOrderedTreeMap {
    mutating func insert(_ element: (key: Key, value: Value), at i: Int, in key: Key) {
        var s = subtree(for: key)!
        s.insert(element, at: i)
        self = s.tree
    }
    mutating func remove(at i: Int, in key: Key) -> Element {
        var s = subtree(for: key)!
        let e = s[i]
        precondition(s.subtree(at: i).count == 0, "You cannot remove a node with children.")
        s.remove(at: i)
        self = s.tree
        return e
    }
}
public extension PDOrderedTreeMap {
    typealias Selection = PDOrderedTreeMapSelection<Key>
}

/// Designates selected portion in the tree.
///
/// This has been designed to provide best performance.
/// Solving explicit index from `OrderedTreeMap` takes O(n log(n)),
/// therefore highly discouraged.
/// We need to record indices to avoid such index resolution.
///
public enum PDOrderedTreeMapSelection<Key> where Key: Comparable {
    /// Only values for the keys has been changed.
    /// No change in topology at all.
    /// Zero-length key-set effectively makes no-op.
    case value(Key)
    /// Topology of direct subtrees of subtree for the key has been changed.
    /// Target key itself has not been changed.
    /// This also can represents an insertion/removal position
    /// with zero-length range.
    case subtrees(Range<Int>, in: Key)
}
public extension PDOrderedTreeMapSelection {
    /// We cannot know count in O(1) as `.subtrees`
    /// includes all descendant nodes.
    var isEmpty: Bool {
        switch self {
        case .value(_):             return false
        case .subtrees(let r,_):    return r.isEmpty
        }
    }
}
