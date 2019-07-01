//
//  PDTimeline.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

/// Collection of time-points, snapshots and changed ranges.
///
/// Timeline organizes each component like this.
///
///     .                   .                   .
///     .                   .                   .
///     time0               .                   .
///     snapshot0           .                   .
///     .                   .                   .
///     point0.old.range -→ point0.new.range    .
///     .                   .                   .
///     .                   time1               .
///     .                   snapshot1           .
///     .                   .                   .
///     .                   point1.old.range -→ point2.new.range
///     .                   .                   .
///     .                   .                   time2
///     .                   .                   snapshot1
///     .                   .                   .
///     .                   .                   .
///
/// A step keeps `old` and `new` points. Each point have `time`
/// and `snapshot`.
///
/// - Note:
///     `time` and `snapshot` is always coupled. That means,
///     if `time`s are equal, `snapshot`s are also equal.
///     This is a device to make equality check to `O(1)`.
///
/// Each point also keeps edited `range`.
///
/// - Note:
///     As `range` is consecutive, discrete changes need to be recorded separately.
///     This is sane decision because non-consecutive changes
///     very unlikely to have batch processing.
///
/// A step's `new` and next step `old` points share equal `time` and `snapshot`.
///
/// - Note:
///     Two consecutive steps DO NOT share the edited ranges
///     despite two consecutive steps share intersecting `time` and `snapshot`,
///     Edited ranges are all diferent for each step's `old` and `new` points.
///
/// A timeline is designed for large, homogeneous collection types.
/// Therefore, snapshot should define an index type to select item in the collection.
/// Generic algorithm for heterogeneous collection cannot be defined.
///
/// Global Uniqueness of Time-Point
/// -------------------------------
/// Please note that all time-points are **globally-unique**.
/// This means, two timelines with equal change-set can be treated as
/// different if their changes are made at different time-point. The only exception
/// is copied timeline. They have equal steps and points, and will be treated
/// as equal until you make changes.
///
/// - Note:
///     Time-points in timeline must be "infinite resolution" conceptually.
///     `PDTimestamp` satisfies this requirement.
///     No operations can happend at same time as resolution is infinite,
///
/// Datastructures using timeline are supposed to record time-point implicitly.
///
public struct PDTimeline<Step>:
PDTimelineProtocol,
CustomReflectable where
Step: PDTimelineStepProtocol {
    private(set) var impl = PDList<Step>()
    mutating func record(_ s: Step) {
        steps.last?.preconditionContinuity(to: s)
        impl.append(s)
    }
    mutating func record<C>(contentsOf other: C) where C: Collection, C.Element == Step {
        guard !other.isEmpty else { return }
        steps.last?.preconditionContinuity(to: other.first!)
        impl.append(contentsOf: other)
    }
    mutating func record(contentsOf other: PDTimeline) {
        record(contentsOf: other.steps)
    }
    public init() {}
}
public extension PDTimeline {
    typealias Time = PDTimestamp
    typealias Snapshot = Step.Snapshot
    init(_ x: Step) {
        impl.append(x)
    }
    /// Returns whether this timeline is continuous to supplied timeline.
    ///
    /// This function returns `true` if
    /// - `self.steps.isEmpty` or
    /// - `other.steps.isEmpty` or
    /// - `steps.last!.isContinuous(to: other.steps.first!)`
    func isContinuous(to other: PDTimeline) -> Bool {
        let a = self
        let b = other
        guard !a.steps.isEmpty else { return true }
        guard !b.steps.isEmpty else { return true }
        return a.steps.last!.isContinuous(to: b.steps.first!)
    }
    /// This is opposite of `isContinuous(from:)`.
    /// See the function for details.
    func isContinuous(from other: PDTimeline) -> Bool {
        return other.isContinuous(to: self)
    }
    /// - Returns:
    ///     `nil` if there's no matching time in this timeline.
    func suffix(since v: PDTimestamp) -> PDTimeline? {
        guard let i = points.lastIndex(where: { p in p.time == v }) else { return nil }
        let xs = steps[i...]
        var tl = PDTimeline()
        tl.record(contentsOf: xs)
        return tl
    }
}
public extension PDTimeline {
    func reversed() -> PDTimeline {
        var q = PDTimeline()
        for x in steps.lazy.reversed() {
            let x1 = x.reversed()
            q.record(x1)
        }
        return q
    }
}
public extension PDTimeline {
    mutating func replay(_ tx: PDTimeline) {
        guard !tx.steps.isEmpty else { return }
        precondition(steps.isEmpty || steps.last?.new.time == tx.steps.first?.old.time)
        for x in tx.steps { record(x) }
    }
    mutating func replay<T>(_ tx: T) where T:PDTimelineProtocol, T.Step == Step {
        guard !tx.steps.isEmpty else { return }
        precondition(steps.isEmpty || steps.last?.new.time == tx.steps.first?.old.time)
        for x in tx.steps { record(x) }
    }
}
