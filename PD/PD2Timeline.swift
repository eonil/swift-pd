//
//  PD2Timeline.swift
//  PD
//
//  Created by Henry on 2019/06/20.
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
///     `PD2Timestamp` satisfies this requirement.
///     No operations can happend at same time as resolution is infinite,
///
/// Datastructures using timeline are supposed to record time-point implicitly.
///
public protocol PD2TimelineProtocol {
    associatedtype Time: Equatable
    associatedtype Snapshot: Collection
    associatedtype Steps: RandomAccessCollection
        where Steps.Element == Step
    associatedtype Step

    var steps: Steps { get }

    /// Returns whether this timeline is continuous to supplied timeline.
    ///
    /// This function returns `true` if
    /// - `self.steps.isEmpty` or
    /// - `other.steps.isEmpty` or
    /// - `steps.last!.isContinuous(to: other.steps.first!)`
    func isContinuous(to other: Self) -> Bool
    /// This is opposite of `isContinuous(from:)`.
    /// See the function for details.
    func isContinuous(from other: Self) -> Bool

    /// - Returns:
    ///     `nil` if there's no matching time in this timeline.
    func suffix(since: Time) -> Self?
}
protocol PD2MutableTimelineProtocol: PD2TimelineProtocol {
    mutating func record(_ s: Step)
    mutating func record<C>(contentsOf other: C) where C: Collection, C.Element == Step
    mutating func record(contentsOf other: Self)
}

protocol PD2TimelineStepProtocol {
    /// Returns whether this step is continuous to supplied step.
    ///
    /// This function returns `true` if
    /// - `new.time == other.old.verion`.
    func isContinuous(to other: Self) -> Bool
    /// This is opposite of `isContinuous(from:)`.
    /// See the function for details.
    func isContinuous(from other: Self) -> Bool
}

public struct PD2Timeline<Snapshot>:
PD2TimelineProtocol,
PD2MutableTimelineProtocol where
Snapshot: Collection {
    private var impl = PDList<Step>()

    public typealias Time = PD2Timestamp
    public init() {}
    public init(_ x: Step) {
        impl.append(x)
    }

    public func isContinuous(to other: PD2Timeline<Snapshot>) -> Bool {
        let a = self
        let b = other
        guard !a.steps.isEmpty else { return true }
        guard !b.steps.isEmpty else { return true }
        return a.steps.last!.isContinuous(to: b.steps.first!)
    }
    public func isContinuous(from other: PD2Timeline<Snapshot>) -> Bool {
        return other.isContinuous(to: self)
    }
    public func suffix(since v: PD2Timestamp) -> PD2Timeline<Snapshot>? {
        guard let i = points.lastIndex(where: { p in p.time == v }) else { return nil }
        let xs = steps[i...]
        var tl = PD2Timeline()
        tl.record(contentsOf: xs)
        return tl
    }

    mutating func record(_ s: Step) {
        steps.last?.preconditionContinuity(to: s)
        impl.append(s)
    }
    mutating func record<C>(contentsOf other: C) where C: Collection, C.Element == Step {
        guard !other.isEmpty else { return }
        steps.last?.preconditionContinuity(to: other.first!)
        impl.append(contentsOf: other)
    }
    mutating func record(contentsOf other: PD2Timeline) {
        record(contentsOf: other.steps)
    }

    public var steps: Steps {
        return Steps(impl: impl)
    }
    public struct Steps: RandomAccessCollection {
        fileprivate var impl: PDList<Step>
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public subscript(_ i: Int) -> Step {
            return impl[i]
        }
    }
    /// Represents changes from a time-point to next time-point.
    /// Each consecutive steps always share single time and snapshot values,
    /// but their `slice`s can be different.
    ///
    /// It's NOT allowed to have `old.time == new.time`.
    /// Such step is an error and timeline NEVER make such step.
    public struct Step {
        public var old: Point
        public var new: Point
    }
    public struct Point {
        /// Unique identifier of this time-point.
        public let time: Time
        /// Range selected for editing at this time-point.
        public let range: Range<Snapshot.Index>
        /// Whole collection snapshot at this time-point.
        public let snapshot: Snapshot
        public var slice: Snapshot.SubSequence {
            return snapshot[range]
        }
    }
}
public extension PD2Timeline {
    var points: Points {
        return Points(impl: impl)
    }
    struct Points: RandomAccessCollection {
        fileprivate var impl: PDList<Step>
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.isEmpty ? 0 : impl.endIndex + 1
        }
        public subscript(_ i: Int) -> Point {
            return i == impl.endIndex
                ? impl[i-1].new
                : impl[i].old
        }
    }
}

public extension PD2Timeline {
    func reversed() -> PD2Timeline {
        var q = PD2Timeline()
        for x in steps.lazy.reversed() {
            let x1 = x.reversed()
            q.record(x1)
        }
        return q
    }
}
public extension PD2Timeline.Step {
    func isContinuous(to other: PD2Timeline.Step) -> Bool {
        let a = self
        let b = other
        return a.new.time == b.old.time
    }
    func isContinuous(from other: PD2Timeline.Step) -> Bool {
        return other.isContinuous(to: self)
    }
    func reversed() -> PD2Timeline.Step {
        return PD2Timeline.Step(
            old: new,
            new: old)
    }
}
extension PD2Timeline.Step {
    func preconditionContinuity(to other: PD2Timeline.Step) {
        precondition(
            isContinuous(to: other),
            "This timeline and supplied timeline are not continuous.")
    }
}

extension PD2Timeline {
    mutating func replay(_ x: PD2Timeline) {
        if let p = steps.last {
            // Some steps.
            // Seek for lastest matching time
            // and replay from there.
            let v = p.new.time
            guard let x1 = x.suffix(since: v) else {
                fatalError("Supplied timeline is not consecutive.")
            }
            guard !x1.steps.isEmpty else { return }
            record(contentsOf: x1)
        }
        else {
            // No step.
            // Just append all.
            record(contentsOf: x)
        }
    }
//    mutating func replay(_ x: PD2Timeline, always a: Bool) {
//        guard !x.steps.isEmpty else { return }
//        if let p = steps.last {
//            // Some steps.
//            // Seek for lastest matching time
//            // and replay afterwords.
//            let v = p.new.time
//            if let x1 = x.suffix(since: v) {
//                // Consecutive timeline.
//                guard !x1.steps.isEmpty else { return }
//                record(contentsOf: x1)
//            }
//            else {
//                // Non-consecutive timeline.
//                guard a else {
//                    fatalError("Supplied timeline is not consecutive.")
//                }
//                let s = p.new.replacementStepping(to: x.steps.first!.old)
//                record(s)
//                record(contentsOf: x)
//            }
//        }
//        else {
//            // No step.
//            // Just append all.
//            record(contentsOf: x)
//        }
//    }
}

extension PD2Timeline.Point {
    /// Makes a stepping that replaces latest snapshot with `p.new`.
    func replacementStepping(to p: PD2Timeline.Point) -> PD2Timeline.Step {
        let r = snapshot.startIndex..<snapshot.endIndex
        let r1 = p.snapshot.startIndex..<p.snapshot.endIndex
        return PD2Timeline.Step(
            old: PD2Timeline.Point(
                time: time,
                range: r,
                snapshot: snapshot),
            new: PD2Timeline.Point(
                time: p.time,
                range: r1,
                snapshot: p.snapshot))
    }
}

