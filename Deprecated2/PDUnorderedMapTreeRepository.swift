//
//  PDUnorderedMapTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

import Foundation
import BTree

/// A repository for unordered map-trees.
@available(*,deprecated: 0, message: "Single element rooted tree doesn't make sense. This type will be removed soon. Use PDOrderedRootlessMapTreeRepository instead of.")
public struct PDUnorderedMapTreeRepository<Key,Value>:
PDRepositoryProtocol where
Key: Comparable {
    private(set) var impl = Timeline()
    private var defaultRootElement: Element
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? defaultSnapshot
    }
    var defaultSnapshot: Snapshot {
        return Snapshot(defaultRootElement)
    }
    mutating func recordValuesStepping(at ks: PDSet<Key>, with s: Snapshot) {
        if let p = impl.steps.last?.new {
            let x = Step.values(
                from: (p.time, p.snapshot),
                to: (PDTimestamp(),s),
                at: ks)
            impl.record(x)
        }
        else {
            let x = Step.values(
                from: (PDTimestamp(), defaultSnapshot),
                to: (PDTimestamp(),s),
                at: ks)
            impl.record(x)
        }
    }
    mutating func recordSubtreesStepping(from a: PDSet<Key>, to b: PDSet<Key>, in pk: Key, with s: Snapshot) {
        if let p = impl.steps.last?.new {
            let x = Step.subtrees(
                from: (p.time, p.snapshot, a),
                to: (PDTimestamp(), s, b),
                in: pk)
            impl.record(x)
        }
        else {
            let x = Step.subtrees(
                from: (PDTimestamp(), defaultSnapshot, a),
                to: (PDTimestamp(), s, b),
                in: pk)
            impl.record(x)
        }
    }
}
public extension PDUnorderedMapTreeRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Step = PDUnorderedMapTreeStep<Snapshot>
    typealias Snapshot = PDUnorderedMapTree<Key,Value>
    typealias Element = Snapshot.Element
//    typealias Selection = Snapshot.Selection

    init(_ e: Element) {
        defaultRootElement = e
    }
    var timeline: Timeline {
        return impl
    }
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    var latestOnly: PDUnorderedMapTreeRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
}
public extension PDUnorderedMapTreeRepository {
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
        recordValuesStepping(at: ks, with: s)
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
        recordSubtreesStepping(from: [], to: ks, in: pk, with: s)
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
        recordSubtreesStepping(from: PDSet(ks), to: [], in: pk, with: s)
    }
    mutating func removeSubtree(_ k: Key, in pk: Key) {
        removeSubtrees(contentsOf: [k], in: pk)
    }
}

//extension PDUnorderedMapTree: PDSnapshotProtocol {}
//public extension PDUnorderedMapTree {
//    enum Selection {
//        /// Only values for the keys has been changed.
//        /// No change in topology at all.
//        /// Zero-length key-set effectively makes no-op.
//        case values(PDSet<Key>)
//        /// Topology of direct subtrees of subtree for the key has been changed.
//        /// Target key itself has not been changed.
//        /// This also can represents an insertion/removal position
//        /// with zero-length range.
//        case subtrees(PDSet<Key>, in: Key)
//    }
//}
