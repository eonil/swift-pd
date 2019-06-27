//
//  PDKVLTRepository.swift
//  PD
//
//  Created by Henry on 2019/06/27.
//

import Tree

public struct PDKVLTRepository<Key,Value>:
PDRepositoryProtocol, ReplaceableMapTreeStorage where
Key: Comparable {
    private(set) var impl: Timeline
    public init() {
        impl = Timeline()
    }
    init(impl x: Timeline) {
        impl = x
    }
}
public extension PDKVLTRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Snapshot = KVLTStorage<Key,Value>
    var timeline: Timeline {
        return impl
    }
    var latestOnly: PDKVLTRepository {
        guard let x = impl.steps.last else { return self }
        return PDKVLTRepository(impl: Timeline(x))
    }
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
}
public extension PDKVLTRepository {
    typealias Collection = Snapshot.Collection
    typealias List = Snapshot.List
    typealias Tree = Snapshot.Tree
    var collection: List {
        let s = impl.steps.last?.new.snapshot ?? Snapshot()
        return s.collection
    }
    mutating func replace<C>(_ r: Range<Int>, in pk: PDKVLTRepository.Key?, with c: C) where C : Swift.Collection, Key == C.Element.Key, Value == C.Element.Value, C.Element : MapTree, Collection.Index == C.Element.Collection.Index {
        let x1 = impl.steps.last
        let p1 = x1?.new

        let t1 = p1?.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let s1 = impl.steps.last?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.replace(r, in: pk, with: c)
        let r1 = r
        let r2 = r.lowerBound..<r.lowerBound+c.count

        let x2 = Step.subtrees(from: (t1,s1,r1), to: (t2,s2,r2), in: pk)
        impl.record(x2)
    }
}

public extension PDKVLTRepository {
    enum Step: PDTimelineStepProtocol {
        case values(from: ValuesPoint, to: ValuesPoint, at: PDSet<Key>)
        case subtrees(from: SubtreePoint, to: SubtreePoint, in: Key?)
    }
    typealias Point = PDTimelineStepPoint<Snapshot>
}
public extension PDKVLTRepository.Step {
    typealias Snapshot = PDKVLTRepository.Snapshot
    typealias Point = PDKVLTRepository.Point
    typealias ValuesPoint = (time: PDTimestamp, snapshot: Snapshot)
    typealias SubtreePoint = (time: PDTimestamp, snapshot: Snapshot, range: Range<Int>)
    var old: Point {
        switch self {
        case let .values(a,_,_):    return Point(time: a.0, snapshot: a.1)
        case let .subtrees(a,_,_):  return Point(time: a.0, snapshot: a.1)
        }
    }
    var new: Point {
        switch self {
        case let .values(_,b,_):    return Point(time: b.0, snapshot: b.1)
        case let .subtrees(_,b,_):  return Point(time: b.0, snapshot: b.1)
        }
    }
    func reversed() -> PDKVLTRepository.Step {
        switch self {
        case let .values(a, b, ks):     return .values(from: b, to: a, at: ks)
        case let .subtrees(a, b, k):    return .subtrees(from: b, to: a, in: k)
        }
    }
}
