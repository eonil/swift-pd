//
//  PDOrderedMapTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/26.
//

import Foundation
import BTree

/// A repository for ordered map-trees.
public struct PDOrderedMapTreeRepository<Key,Value>:
Collection,
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
public extension PDOrderedMapTreeRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Step = PDOrderedMapTreeStep<Snapshot>
    typealias Snapshot = PDOrderedMapTree<Key,Value>

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
    mutating func replaceValues<C>(_ es: C) where C: Collection, C.Element == Element {
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
        s.insert(contentsOf: es, at: i, in: pk)
        recordSubtreesStepping(from: i..<i, to: i..<i+1, in: pk, with: s)
    }
    mutating func insertSubtree(_ e: Element, at i: Int, in pk: Key?) {
        insertSubtrees(contentsOf: [e], at: i, in: pk)
    }
    mutating func removeSubtrees(_ r: Range<Int>, in pk: Key?) {
        var s = latestSnapshot
        s.removeSubtrees(r, in: pk)
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
public extension PDOrderedMapTreeRepository {
    typealias Iterator = Snapshot.Iterator
    typealias Index = Snapshot.Index
    typealias Element = Snapshot.Element
    func makeIterator() -> Iterator {
        return latestSnapshot.makeIterator()
    }
    var startIndex: Index {
        return latestSnapshot.startIndex
    }
    var endIndex: Index {
        return latestSnapshot.endIndex
    }
    func index(after i: Index) -> Index {
        return latestSnapshot.index(after: i)
    }
    subscript(_ i: Index) -> Element {
        return latestSnapshot[i]
    }
}

public extension PDOrderedMapTreeRepository {
    /// Replay with mapping keys and values.
    /// This function actually performs all operations one-by-one.
    /// - Parameter with fx:
    ///     Mapping function.
    ///     All keys in tree after mapping must be unique.
    mutating func replay<K1,V1>(_ x: PDOrderedMapTreeRepository<K1,V1>.Step, with fx: (PDOrderedMapTreeRepository<K1,V1>.Element) -> (Element)) where K1: Hashable {
        switch x {
        case let .values(_,b1,ks1):
            let es = ks1.map({ k1 in fx((k1,b1.snapshot[k1])) })
            replaceValues(es)
        case let .subtrees(a1,b1,pk1):
            var s = latestSnapshot
            let pk = (pk1 == nil ? nil as Key? : fx((pk1!,a1.snapshot[pk1!])).0) as Key?
            let es = b1.snapshot.subtree(for: pk1)[b1.range].map({ e in fx(e) })
            s.removeSubtrees(a1.range, in: pk)
            s.insert(contentsOf: es, at: b1.range.lowerBound, in: pk)
            recordSubtreesStepping(from: a1.range, to: b1.range, in: pk, with: s)
        }
    }
}
