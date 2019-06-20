//
//  PDTimelineStepping.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

public extension PDTimelineProtocol where
Self.Index : Strideable,
//Self.Indices == Range<Self.Index>,
Self.Index.Stride == Int {
    typealias Stepping = PDTimelineStepping<Self>
    typealias SteppingCollection = PDTimelineSteppingCollection<Self>
    var steppins: SteppingCollection {
        return SteppingCollection(impl: self)
    }

}
public struct PDTimelineSteppingCollection<Timeline>: RandomAccessCollection where
Timeline: PDTimelineProtocol,
Timeline.Index : Strideable,
//Self.Indices == Range<Self.Index>,
Timeline.Index.Stride == Int {
    private(set) var impl: Timeline
    public var startIndex: Timeline.Index {
        return impl.changes.startIndex
    }
    public var endIndex: Timeline.Index {
        return impl.changes.endIndex
    }
    public subscript(_ i: Timeline.Index) -> Timeline.Stepping {
        let i1 = impl.changes.index(after: i)
        return Timeline.Stepping(
            from: Timeline.Stepping.Point(
                version: impl.versions[i],
                snapshot: impl.snapshots[i],
                portion: impl.changes[i].from),
            to: Timeline.Stepping.Point(
                version: impl.versions[i1],
                snapshot: impl.snapshots[i1],
                portion: impl.changes[i].to))
    }
}
public struct PDTimelineStepping<Timeline> where
Timeline: PDTimelineProtocol {
    public typealias Point = PDTimelineSteppingPoint<Timeline>
    public var from: Point
    public var to: Point
}

public struct PDTimelineSteppingPoint<Timeline> where
Timeline: PDTimelineProtocol {
    public var version: Timeline.Version
    public var snapshot: Timeline.Snapshot
    public var portion: Timeline.Change.Portion
}
