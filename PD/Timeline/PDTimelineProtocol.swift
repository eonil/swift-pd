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

    /// Finds an interaction point and returns steps since the point including the point.
    /// - Returns:
    ///     `nil` if there's no matching time in this timeline.
    func suffix(since v: PDTimestamp) -> Self?
    func reversed() -> Self
}

public protocol PDReplaceableMutableTimelineProtocol: PDTimelineProtocol {
    init()
    init(_ x: Step)

//    mutating func record(_ s: Step)
    mutating func replay(_ x: Self)

}
