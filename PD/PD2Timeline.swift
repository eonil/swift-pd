//
//  PD2Timeline.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

/// Collection of versions, snapshots and changed ranges.
///
/// Timeline organizes each component like this.
///
///     .                   .                   .
///     .                   .                   .
///     version0            .                   .
///     snapshot0           .                   .
///     .                   .                   .
///     point0.old.slice -→ point0.new.slice    .
///     .                   .                   .
///     .                   version1            .
///     .                   snapshot1           .
///     .                   .                   .
///     .                   point1.old.slice -→ point2.new.slice
///     .                   .                   .
///     .                   .                   version2
///     .                   .                   snapshot1
///     .                   .                   .
///     .                   .                   .
///
/// A step keeps `old` and `new` points.
/// Each point keeps `slice` which keeps edited range.
/// A step and next step shares equal `version` and `snapshot`.
/// Note that two consecutive steps DO NOT share the edited ranges.
/// They shares intersecting `version` and `snapshot`, but edited
/// ranges are all diferent for each step's `old` and `new` points.
///
/// A timeline is designed for large, homogeneous collection types.
/// Therefore, snapshot should define an index type to select item in the collection.
/// Generic algorithm for heterogeneous collection cannot be defined.
public protocol PD2TimelineProtocol {
    associatedtype Version: Equatable
    associatedtype Snapshot: Collection
    associatedtype Steps: RandomAccessCollection

    var steps: Steps { get }
    /// - Returns:
    ///     An empty timeline if there's no matching version in this timeline.
    func steps(since: Version) -> Self
}

public struct PD2Timeline<Snapshot>: PD2TimelineProtocol where
Snapshot: Collection {
    private var impl = PDList<Step>()

    public typealias Version = AnyHashable
    mutating func record(_ s: Step) {
        precondition(
            steps.isEmpty || steps.last!.new.version == s.old.version,
            "Supplied step's `.from.point.version` SHOULD match with last step's `.to.point.version`.")
        impl.append(s)
    }
    mutating func record<C>(contentsOf other: C) where C: Collection, C.Element == Step {
        impl.append(contentsOf: other)
    }
    mutating func record(contentsOf other: PD2Timeline) {
        impl.append(contentsOf: other.impl)
    }

    public var steps: Steps {
        return Steps(impl: impl)
    }
    public func steps(since v: AnyHashable) -> PD2Timeline<Snapshot> {
        guard let i = points.lastIndex(where: { p in p.version == v }) else { return PD2Timeline() }
        let xs = steps[i...]
        var tl = PD2Timeline()
        tl.record(contentsOf: xs)
        return tl
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
    /// Each consecutive steps always share single version and snapshot,
    /// but their `slice`s can be different.
    ///
    /// It's allowed to have `old.version == new.version`.
    /// This is used to represent no change but empty placeholder.
    /// Generally you are supposed to minimize this kind of cases,
    /// but, it is allowed. If two points have same version, their snapshots
    /// SHOULD be equal.
    public struct Step {
        public var old: Point
        public var new: Point
    }
    public struct Point {
        /// Unique identifier of this time-point.
        public let version: Version
        /// Range selected for editing at this time-point.
        /// `Snapshot.SubSeqeunce` doesn't have to be
        /// `Slice` type.
        public let slice: Slice<Snapshot>
        /// Whole collection snapshot at this time-point.
        public var snapshot: Snapshot {
            return slice.base
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
            return impl.endIndex + 1
        }
        public subscript(_ i: Int) -> Point {
            return i == impl.endIndex
                ? impl[i].new
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
    func reversed() -> PD2Timeline.Step {
        return PD2Timeline.Step(
            old: new,
            new: old)
    }
}

extension PD2Timeline {
    mutating func replay(_ x: PD2Timeline) {
        if let p = steps.last {
            // Some steps.
            // Seek for lastest matching version
            // and replay afterwords.
            let v = p.new.version
            let x1 = x.steps(since: v)
            guard !x1.steps.isEmpty else { return }
            record(contentsOf: x1)
        }
        else {
            // No step.
            // Just append all.
            record(contentsOf: x)
        }
    }
}
