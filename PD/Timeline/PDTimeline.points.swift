//
//  PDTimeline.points.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public extension PDTimeline {
    var points: Points {
        return Points(impl: impl)
    }
    struct Points: RandomAccessCollection {
        private(set) var impl: PDList<Step>
    }
}

public extension PDTimeline.Points {
    typealias Element = PDTimeline.Point
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.isEmpty ? 0 : impl.endIndex + 1
    }
    subscript(_ i: Int) -> PDTimeline.Points.Element {
        return i == impl.endIndex
            ? impl[i-1].new
            : impl[i].old
    }
}

public protocol PDTimelineStepPointProtocol {
    associatedtype Snapshot
    /// Unique identifier of this time-point.
    var time: PDTimestamp { get }
    /// Whole collection snapshot at this time-point.
    var snapshot: Snapshot { get }
}
