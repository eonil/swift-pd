//
//  PDListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

public struct PDListRepository<Element>:
PDRepositoryProtocol,
Sequence,
Collection,
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection {
    private(set) var impl = Timeline()
    public init() {}
    public init(timeline z: Timeline) {
        impl = z
    }
    public mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot()
    }
    mutating func recordStepping(from a: Range<Int>, to b: Range<Int>, with s: Snapshot) {
        let t = PDTimestamp()
        if let p = impl.steps.last?.new {
            let x = Timeline.Step(
                old: Timeline.Point(
                    time: p.time,
                    snapshot: p.snapshot,
                    selection: a),
                new: Timeline.Point(
                    time: t,
                    snapshot: s,
                    selection: b))
            impl.record(x)
        }
        else {
            let x = Timeline.Step(
                old: Timeline.Point(
                    time: t,
                    snapshot: latestSnapshot,
                    selection: a),
                new: Timeline.Point(
                    time: t,
                    snapshot: s,
                    selection: b))
            impl.record(x)
        }
    }
}
public extension PDListRepository {
    typealias Timeline = PDTimeline<Snapshot>
    typealias Snapshot = PDList<Element>

    var timeline: Timeline {
        return impl
    }
    var latestOnly: PDListRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
}
public extension PDListRepository {
    typealias Index = Int
    var startIndex: Index {
        return latestSnapshot.startIndex
    }
    var endIndex: Index {
        return latestSnapshot.endIndex
    }
    subscript(_ i: Index) -> Snapshot.Element {
        get {
            return latestSnapshot[i]
        }
        set(v) {
            let s = latestSnapshot
            var s1 = s
            s1[i] = v
            let a = i..<i.advanced(by: 1)
            let b = a
            recordStepping(from: a, to: b, with: s)
        }
    }
    mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        let q = subrange.relative(to: self)
        var s = latestSnapshot
        s.replaceSubrange(q, with: newElements)
        let a = q
        let b = q.lowerBound..<q.lowerBound.advanced(by: newElements.count)
        recordStepping(from: a, to: b, with: s)
    }
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        let s = latestSnapshot
        replaceSubrange(s.indices, with: [])
    }
//    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
//        let s = latestSnapshot
//        replaceSubrange(s.indices, with: [])
//    }
}
