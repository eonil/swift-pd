//
//  PDTimeline.steps.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public extension PDTimeline {
    typealias Point = Step.Point
    var steps: Steps {
        return Steps(impl: impl)
    }
    struct Steps: RandomAccessCollection {
        private(set) var impl: PDList<Step>
    }
}
public extension PDTimeline.Steps {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> Step {
        return impl[i]
    }
}

/// Represents changes from a time-point to next time-point.
/// Each consecutive steps always share single time and snapshot values,
/// but their `slice`s can be different.
///
/// It's NOT allowed to have `old.time == new.time`.
/// Such step is an error and timeline NEVER make such step.
///
/// Different repository needs different type of steps.
/// This defines minimum requirements, and each repository
/// define their own step type for their needs.
///
public protocol PDTimelineStepProtocol {
    associatedtype Snapshot
    associatedtype Point: PDTimelineStepPointProtocol where
        Point.Snapshot == Snapshot
    var old: Point { get }
    var new: Point { get }
    /// Returns whether this step is continuous to supplied step.
    ///
    /// This function returns `true` if
    /// - `new.time == other.old.verion`.
    func isContinuous(to other: Self) -> Bool
    /// This is opposite of `isContinuous(from:)`.
    /// See the function for details.
    func isContinuous(from other: Self) -> Bool
    func reversed() -> Self
}
public extension PDTimelineStepProtocol {
    func isContinuous(to other: Self) -> Bool {
        let a = self
        let b = other
        return a.new.time == b.old.time
    }
    func isContinuous(from other: Self) -> Bool {
        return other.isContinuous(to: self)
    }
}
public extension PDTimelineStepProtocol {
    func preconditionContinuity(to other: Self) {
        precondition(
            isContinuous(to: other),
            "This timeline and supplied timeline are not continuous.")
    }
}
