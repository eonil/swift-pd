//
//  PDListRepo.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

public struct PDListRepo<Element>:
PDRepositoryProtocol,
Sequence,
Collection,
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection {
    private(set) var impl = Timeline()
    public init() {}
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
public extension PDListRepo {
    typealias Timeline = PDTimeline<Snapshot>
    typealias Snapshot = PDList<Element>

    var timeline: Timeline {
        return impl
    }
}
public extension PDListRepo {
    typealias Index = Int
    var startIndex: Index { latestSnapshot.startIndex }
    var endIndex: Index { latestSnapshot.endIndex }
    subscript(_ i: Index) -> Snapshot.Element {
        get { latestSnapshot[i]  }
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
        let s = latestSnapshot
        var s1 = s
        s1.replaceSubrange(q, with: newElements)
        let a = q
        let b = q.lowerBound..<q.lowerBound.advanced(by: newElements.count)
        recordStepping(from: a, to: b, with: s)
    }
}
