//
//  PDTimelineProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public protocol PDTimelineProtocol {
    associatedtype Step: PDTimelineStepProtocol
    typealias Time = PDTimestamp
    typealias Point = Step.Point
    typealias Snapshot = Step.Snapshot

    var steps: Steps { get }
    associatedtype Steps: RandomAccessCollection where
        Steps.Index == Int,
        Steps.Element == Step

    /// Finds an interaction point and returns steps since the point
    /// including the target point.
    /// - Returns:
    ///     `nil` if there's no matching time in this timeline.
    ///     This means two timelines are not continuous.
    func suffix(since v: PDTimestamp) -> Self?
    func reversed() -> Self
}

public protocol PDReplaceableMutableTimelineProtocol: PDTimelineProtocol {
    init()
    init(_ x: Step)

//    mutating func record(_ s: Step)

    /// Replays another timeline on this timeline.
    /// Supplied timeline must be exactly continuous from this timeline.
    /// That means last time-point of this timeline must be equal
    /// with first time-point of supplied timeline.
    ///
    ///     self.steps?.new.time == x.steps?.old.time
    ///
    /// If this timeline is empty, all steps in supplied timeline
    /// will be replayed as is.
    ///
    /// If supplied timeline is empty, this is no-op.
    ///
    mutating func replay<T>(_ x: T) where T:PDTimelineProtocol, T.Step == Step
}
