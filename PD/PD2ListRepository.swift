//
//  PD2ListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

/// A list-like repository.
///
/// If you never have made any mutation,
/// timeline must be empty, and this repo works like
/// an empty list.
///
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
    /// Gets a repo with only latest step.
    /// If there's no step, `self` will be returned
    /// which is just an empty repo.
    var latestOnly: PD2ListRepository {
        guard let x = timeline.steps.last else { return self }
        var tl = Timeline()
        tl.record(x)
        return PD2ListRepository(timeline: tl)
    }
}
extension PD2ListRepository: Sequence where
Snapshot: RangeReplaceableCollection {
    public typealias Index = Snapshot.Index
    public typealias Element = Snapshot.Element
    public __consuming func makeIterator() -> Snapshot.Iterator {
        let s = timeline.points.last?.snapshot ?? Snapshot()
        return s.makeIterator()
    }
}

extension PD2ListRepository: Collection where
Snapshot: RangeReplaceableCollection {
    public var startIndex: Snapshot.Index {
        let s = timeline.points.last?.snapshot ?? Snapshot()
        return s.startIndex
    }
    public var endIndex: Snapshot.Index {
        let s = timeline.points.last?.snapshot ?? Snapshot()
        return s.endIndex
    }
    public func index(after i: Snapshot.Index) -> Snapshot.Index {
        let s = timeline.points.last?.snapshot ?? Snapshot()
        return s.index(after: i)
    }
    public subscript(_ i: Snapshot.Index) -> Snapshot.Element {
        let s = timeline.points.last?.snapshot ?? Snapshot()
        return s[i]
    }
}

extension PD2ListRepository: RangeReplaceableCollection where
Snapshot: MutableCollection & RangeReplaceableCollection,
Snapshot.Index: Strideable {
    public init() {
//        let s = Snapshot()
//        let v = PD2Timestamp()
//        let b = s.startIndex..<s.startIndex
//        let m = Slice(base: s, bounds: b)
//        let p = Timeline.Point(version: v, slice: m)
//        let x = Timeline.Step(old: p, new: p)
//        timeline.record(x)
    }
    public mutating func replaceSubrange<C>(_ subrange: Range<Snapshot.Index>, with newElements: __owned C) where C : Collection, Snapshot.Element == C.Element {
        let p = timeline.points.last ?? makeDefaultEmptyPoint()
        let s = p.snapshot
        var s1 = s
        s1.replaceSubrange(subrange, with: newElements)
        let v1 = PD2Timestamp()
        let r1 = subrange.lowerBound..<s1.index(
            subrange.lowerBound,
            offsetBy: newElements.count)
        let p1 = Timeline.Point(version: v1, range: r1, snapshot: s1)
        let x1 = Timeline.Step(old: p, new: p1)
        timeline.record(x1)
    }
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        replaceSubrange(startIndex..<endIndex, with: [])
    }
}

private extension PD2ListRepository where
Snapshot: RangeReplaceableCollection {
    func makeDefaultEmptyPoint() -> Timeline.Point {
        let s = Snapshot()
        let r = s.startIndex..<s.endIndex
        return Timeline.Point(version: PD2Timestamp(), range: r, snapshot: s)
    }
}
