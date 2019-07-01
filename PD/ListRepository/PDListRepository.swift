//
//  PDListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

public struct PDListRepository<Element>:
PDReplayingProtocol,
PDRepositoryProtocol,
PDListRepositoryProtocol,
PDEditableListRepositoryProtocol,
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
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot()
    }
}
public extension PDListRepository {
    typealias Timeline = PDTimeline<PDListStep<PDList<Element>>>
    typealias Step = Timeline.Step
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
    mutating func record(_ x: Step) {
        impl.record(x)
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
            let x1 = impl.steps.last
            let t1 = x1?.new.time ?? PDTimestamp()
            let t2 = PDTimestamp()
            let s1 = latestSnapshot
            var s2 = s1
            s2[i] = v
            let x2 = Step(
                operation: .replace,
                range: i..<i+1,
                old: Step.Point(time: t1, snapshot: s1),
                new: Step.Point(time: t2, snapshot: s2))
            impl.record(x2)
        }
    }
    mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: __owned C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        let q = subrange.relative(to: self)
        let x1 = impl.steps.last
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let s1 = latestSnapshot
        var s2 = s1
        s2.replaceSubrange(q, with: newElements)
        let x2 = Step(
            operation: .replace,
            range: q,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        replaceSubrange(startIndex..<endIndex, with: EmptyCollection())
    }
}
