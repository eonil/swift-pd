//
//  PD2TreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

public struct PD2TreeRepository<Snapshot>: PD2RepositoryProtocol where
Snapshot: TreeProtocol {
    public typealias Timeline = PD2Timeline<Snapshot>
    public private(set) var timeline = Timeline()
    private func preconditionNonEmptyPoints() {
        precondition(
            !timeline.points.isEmpty,
            "Timeline is empty. You cannot perform editing on empty timeline.")
    }

    public mutating func replay(_ x: PD2TreeRepository<Snapshot>.Timeline) {
        timeline.replay(x)
    }
}

extension PD2TreeRepository: Sequence where
Snapshot: Sequence {
    public __consuming func makeIterator() -> Snapshot.Iterator {
        let p = timeline.points.last!
        return p.snapshot.makeIterator()
    }
}

extension PD2TreeRepository: Collection where
Snapshot: Collection {
    public var startIndex: Snapshot.Index {
        let s = timeline.points.last!.snapshot
        return s.startIndex
    }
    public var endIndex: Snapshot.Index {
        let s = timeline.points.last!.snapshot
        return s.endIndex
    }
    public func index(after i: Snapshot.Index) -> Snapshot.Index {
        let s = timeline.points.last!.snapshot
        return s.index(after: i)
    }
    public subscript(_ i: Snapshot.Index) -> Snapshot.Element {
        let s = timeline.points.last!.snapshot
        return s[i]
    }
}

extension PD2TreeRepository where
Snapshot: MutableTreeProtocol,
Snapshot.Index == IndexPath,
Snapshot.SubtreeCollection.Index == IndexPath.Element {
    public subscript(_ i: IndexPath) -> Snapshot.Element {
        get {
            let s = timeline.points.last!.snapshot
            return s[i]
        }
        set(w) {
            preconditionNonEmptyPoints()
            let p = timeline.points.last!
            var s = p.snapshot
            let v = p.version
            let m = Slice(base: s, bounds: i..<s.index(after: i))
            s[i] = w
            let v1 = AnyHashable(PDIdentity())
            let m1 = Slice(
                base: s,
                bounds: i..<s.index(after: i))
            let x = Timeline.Step(
                old: Timeline.Point(version: v, slice: m),
                new: Timeline.Point(version: v1, slice: m1))
            timeline.record(x)
        }
    }
    public mutating func insert(_ e: Snapshot.Element, at i: IndexPath) {
        preconditionNonEmptyPoints()
        let p = timeline.points.last!
        let v = p.version
        var s = p.snapshot
        let m = Slice(base: s, bounds: i..<i)
        s.insert(e, at: i)
        let v1 = AnyHashable(PDIdentity())
        let m1 = Slice(base: s, bounds: i..<s.index(after: i))
        let x = Timeline.Step(
            old: Timeline.Point(version: v, slice: m),
            new: Timeline.Point(version: v1, slice: m1))
        timeline.record(x)
    }
    public mutating func remove(at i: Snapshot.Index) {
        preconditionNonEmptyPoints()
        let p = timeline.points.last!
        let v = p.version
        var s = p.snapshot
        let m = Slice(base: s, bounds: i..<s.index(after: i))
        s.remove(at: i)
        let v1 = AnyHashable(PDIdentity())
        let m1 = Slice(base: s, bounds: i..<i)
        let x = Timeline.Step(
            old: Timeline.Point(version: v, slice: m),
            new: Timeline.Point(version: v1, slice: m1))
        timeline.record(x)
    }
}
