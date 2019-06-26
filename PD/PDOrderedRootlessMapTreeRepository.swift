//
//  PDOrderedRootlessMapTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/26.
//

import Foundation
import BTree

/// A repository for ordered map-trees.
///
/// You can initialize this repository without any parameter
/// as this repository does not require root element.
///
public struct PDOrderedRootlessMapTreeRepository<Key,Value>:
PDRepositoryProtocol where
Key: Comparable {
    private(set) var impl = Timeline()
    public init() {}
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? defaultSnapshot
    }
    var defaultSnapshot: Snapshot {
        return Snapshot()
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
    mutating func recordSubtreesStepping(from a: Range<Int>, to b: Range<Int>, in pk: Key?, with s: Snapshot) {
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
public extension PDOrderedRootlessMapTreeRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Step = PDOrderedRootlessMapTreeStep<Snapshot>
    typealias Snapshot = PDOrderedRootlessMapTree<Key,Value>
    typealias Element = Snapshot.Element

    var timeline: Timeline {
        return impl
    }
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    var latestOnly: PDOrderedRootlessMapTreeRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
}
public extension PDOrderedRootlessMapTreeRepository {
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
    mutating func insertSubtrees<C>(contentsOf es: C, at i: Int, in pk: Key?) where C: Collection, C.Element == Element {
        var s = latestSnapshot
        var x = s.subtree(for: pk)
        x.insert(contentsOf: es, at: i)
        s = x.tree
        recordSubtreesStepping(from: i..<i, to: i..<i+1, in: pk, with: s)
    }
    mutating func insertSubtree(_ e: Element, at i: Int, in pk: Key?) {
        insertSubtrees(contentsOf: [e], at: i, in: pk)
    }
    mutating func removeSubtrees(_ r: Range<Int>, in pk: Key?) {
        var s = latestSnapshot
        var x = s.subtree(for: pk)
        x.removeSubrange(r)
        s = x.tree
        recordSubtreesStepping(from: r, to: r.lowerBound..<r.lowerBound, in: pk, with: s)
    }
    mutating func removeSubtree(at i: Int, in pk: Key?) {
        removeSubtrees(i..<i, in: pk)
    }
    mutating func removeAll() {
        let s = latestSnapshot
        recordSubtreesStepping(from: 0..<s.count, to: 0..<0, in: nil, with: defaultSnapshot)
    }
}
