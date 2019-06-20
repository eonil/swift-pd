//
//  PD2ListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

public struct PD2ListRepository<Snapshot>: PD2RepositoryProtocol where
Snapshot: RandomAccessCollection {
    public private(set) var timeline = PD2Timeline<Snapshot>()
    private func preconditionNonEmptyPoints() {
        precondition(
            !timeline.points.isEmpty,
            "Timeline is empty. You cannot perform editing on empty timeline.")
    }

    public typealias Timeline = PD2Timeline<Snapshot>
    public mutating func replay(_ x: PD2Timeline<Snapshot>) {
        timeline.replay(x)
    }
}
extension PD2ListRepository: Sequence {
    public typealias Index = Snapshot.Index
    public typealias Element = Snapshot.Element
    public __consuming func makeIterator() -> Snapshot.Iterator {
        preconditionNonEmptyPoints()
        let p = timeline.points.last!.snapshot
        return p.makeIterator()
    }
}

extension PD2ListRepository: Collection {
    public var startIndex: Snapshot.Index {
        preconditionNonEmptyPoints()
        return timeline.points.last!.snapshot.startIndex
    }
    public var endIndex: Snapshot.Index {
        preconditionNonEmptyPoints()
        return timeline.points.last!.snapshot.endIndex
    }
    public func index(after i: Snapshot.Index) -> Snapshot.Index {
        preconditionNonEmptyPoints()
        let p = timeline.points.last!
        return p.snapshot.index(after: i)
    }
    public subscript(_ i: Snapshot.Index) -> Snapshot.Element {
        preconditionNonEmptyPoints()
        return timeline.points.last!.snapshot[i]
    }
}

extension PD2ListRepository: RangeReplaceableCollection where
Snapshot: MutableCollection & RangeReplaceableCollection,
Snapshot.Index: Strideable {
    public init() {
        let s = Snapshot()
        let v = AnyHashable(PDIdentity())
        let b = s.startIndex..<s.startIndex
        let m = Slice(base: s, bounds: b)
        let p = Timeline.Point(version: v, slice: m)
        let x = Timeline.Step(old: p, new: p)
        timeline.record(x)
    }
    public mutating func replaceSubrange<C>(_ subrange: Range<Snapshot.Index>, with newElements: __owned C) where C : Collection, Snapshot.Element == C.Element {
        preconditionNonEmptyPoints()
        let p = timeline.points.last!
        var s = p.snapshot
        s.replaceSubrange(subrange, with: newElements)
        let v1 = AnyHashable(PDIdentity())
        let r1 = subrange.lowerBound..<s.index(
            subrange.lowerBound,
            offsetBy: newElements.count)
        let s1 = Slice(base: s, bounds: r1)
        let p1 = Timeline.Point(version: v1, slice: s1)
        let x1 = Timeline.Step(old: p, new: p1)
        timeline.record(x1)
    }
}
