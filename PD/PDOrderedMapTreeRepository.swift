//
//  PDOrderedMapTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

import Foundation
import BTree

/// A repository for ordered map-trees.
public struct PDOrderedMapTreeRepository<Key,Value>:
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
    mutating func recordSubtreesStepping(from a: Range<Int>, to b: Range<Int>, in pk: Key, with s: Snapshot) {
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
public extension PDOrderedMapTreeRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Step = PDOrderedMapTreeStep<Snapshot>
    typealias Snapshot = PDOrderedMapTree<Key,Value>
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
    var latestOnly: PDOrderedMapTreeRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
}
public extension PDOrderedMapTreeRepository {
    var subtree: Snapshot.Subtree {
        return latestSnapshot.subtree
    }
    func subtree(for k: Key) -> Snapshot.Subtree? {
        return latestSnapshot.subtree(for: k)
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
        recordValuesStepping(at: ks, with: s)
    }
    mutating func replaceSubtrees<C>(_ r: Range<Int>, in pk: Key, with ts: C) where C: Collection, C.Element == Snapshot.Subtree {
        var s = latestSnapshot
        var x = s.subtree(for: pk)!
        x.replaceSubtrees(r, with: ts)
        s = x.tree

        let q = r.lowerBound..<r.lowerBound+ts.count
        recordSubtreesStepping(from: r, to: q, in: pk, with: s)
    }
    mutating func insertSubtrees<C>(contentsOf es: C, at i: Int, in pk: Key) where C: Collection, C.Element == Element {
        let ts = es.lazy.map({ e in Snapshot(e).subtree })
        replaceSubtrees(i..<i, in: pk, with: ts)
    }
    mutating func insertSubtree(_ e: Element, at i: Int, in pk: Key) {
        insertSubtrees(contentsOf: [e], at: i, in: pk)
    }
    mutating func removeSubtrees(_ r: Range<Int>, in pk: Key) {
        replaceSubtrees(r, in: pk, with: [])
    }
    mutating func removeSubtree(at i: Int, in pk: Key) {
        removeSubtrees(i..<i, in: pk)
    }
}

//extension PDOrderedMapTree: PDSnapshotProtocol {}
//public extension PDOrderedMapTree {
//    enum Selection {
//        /// Only values for the keys has been changed.
//        /// No change in topology at all.
//        /// Zero-length key-set effectively makes no-op.
//        case values(PDSet<Key>)
//        /// Topology of direct subtrees of subtree for the key has been changed.
//        /// Target key itself has not been changed.
//        /// This also can represents an insertion/removal position
//        /// with zero-length range.
//        case subtrees(Range<Int>, in: Key)
//    }
//}
