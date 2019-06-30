//
//  PDReplayingProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDReplayingProtocol {
    typealias Timeline = PDTimeline<Step>
    associatedtype Step: PDTimelineStepProtocol

    /// Replays records in timeline automatically from matching time-point.
    ///
    /// This method find matching time-point in supplied timeline and re-apply
    /// changes since the time. If there's no matching time, this method
    /// crashes.
    ///
    mutating func replay(_: Timeline)
}

public extension PDReplayingProtocol {
    mutating func replay(_ x: Step) {
        let tx = Timeline(x)
        replay(tx)
    }
}
