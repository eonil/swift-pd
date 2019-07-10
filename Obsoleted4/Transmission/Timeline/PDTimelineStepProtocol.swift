//
//  PDTimelineStepProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

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
/// Conforming PDTimelineStepProtocol
/// ---------------------------------
/// Define these members.
/// - `Snapshot`
/// - `Point`.
/// Implement these members.
/// - `old`
/// - `new`
/// - `reversed`.
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
    func isContinuous<S>(to other: S) -> Bool where S:PDTimelineStepProtocol
    /// This is opposite of `isContinuous(from:)`.
    /// See the function for details.
    func isContinuous<S>(from other: S) -> Bool where S:PDTimelineStepProtocol
    func reversed() -> Self
}
public extension PDTimelineStepProtocol {
    func isContinuous<S>(to other: S) -> Bool where S:PDTimelineStepProtocol {
        let a = self
        let b = other
        return a.new.time == b.old.time
    }
    func isContinuous<S>(from other: S) -> Bool where S:PDTimelineStepProtocol {
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
