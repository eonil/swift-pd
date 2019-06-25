//
//  PDUnorderedMapTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

import Foundation
import BTree

/// A repository for unordered map-trees.
public struct PDUnorderedMapTreeRepository<Key,Value> where Key: Comparable {
    private(set) var impl = Timeline()
    private var defaultRootElement: Element
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? defaultSnapshot
    }
    var defaultSnapshot: Snapshot {
        return Snapshot(defaultRootElement)
    }
}
public extension PDUnorderedMapTreeRepository {
    typealias Timeline = PDTimeline<Snapshot>
    typealias Snapshot = PDUnorderedMapTree<Key,Value>
    typealias Element = Snapshot.Element
    typealias Selection = Snapshot.Selection

    init(_ e: Element) {
        defaultRootElement = e
    }
    var timeline: Timeline {
        return impl
    }
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    subscript(_ k: Key) -> Value {
        get {
            let s = latestSnapshot
            return s[k]
        }
        set(v) {
            replaceValues([(k,v)])
        }
    }
    /// Replaces existing values for keys with new values.
    /// This does NOT make any change in topology.
    mutating func replaceValues(_ es: [Element]) {
        var s = latestSnapshot
        var ks = PDSet<Key>()
        for e in es {
            s[e.0] = e.1
            ks.insert(e.0)
        }
        impl.recordStepping(
            from: .values(ks),
            to: .values(ks),
            with: s,
            default: Snapshot(defaultRootElement))
    }
    mutating func insertSubtrees<C>(contentsOf es: C, in pk: Key) where C: Collection, C.Element == Element {
        var s = latestSnapshot
        var x = s.subtree(for: pk)!
        var ks = PDSet<Key>()
        for e in es {
            x.insert(e)
            ks.insert(e.0)
        }
        s = x.tree
        impl.recordStepping(
            from: .subtrees([], in: pk),
            to: .subtrees(ks, in: pk),
            with: s,
            default: Snapshot(defaultRootElement))
    }
    mutating func insertSubtree(_ e: Element, in pk: Key) {
        insertSubtrees(contentsOf: [e], in: pk)
    }
    mutating func removeSubtrees<C>(contentsOf ks: C, in pk: Key) where C: Collection, C.Element == Key {
        var s = latestSnapshot
        var x = s.subtree(for: pk)!
        for k in ks {
            x.removeSubtree(k)
        }
        s = x.tree
        impl.recordStepping(
            from: .subtrees(PDSet(ks), in: pk),
            to: .subtrees([], in: pk),
            with: s,
            default: Snapshot(defaultRootElement))
    }
    mutating func removeSubtree(_ k: Key, in pk: Key) {
        removeSubtrees(contentsOf: [k], in: pk)
    }
}

extension PDUnorderedMapTree: PDSnapshotProtocol {}
public extension PDUnorderedMapTree {
    enum Selection {
        /// Only values for the keys has been changed.
        /// No change in topology at all.
        /// Zero-length key-set effectively makes no-op.
        case values(PDSet<Key>)
        /// Topology of direct subtrees of subtree for the key has been changed.
        /// Target key itself has not been changed.
        /// This also can represents an insertion/removal position
        /// with zero-length range.
        case subtrees(PDSet<Key>, in: Key)
    }
}
