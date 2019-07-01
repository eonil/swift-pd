//
//  PDReplayingProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDReplayingProtocol {
    associatedtype Step: PDTimelineStepProtocol

    /// Replays records in timeline automatically from matching time-point.
    ///
    /// This method find matching time-point in supplied timeline and re-apply
    /// changes since the time. If there's no matching time, this method
    /// crashes.
    ///
    mutating func replay<T>(_ tx: T) where T:PDTimelineProtocol, T.Step == Step
}

//public extension PDReplayingProtocol {
//    mutating func replay<S>(_ x: S) where S == Step {
//        let tx = Timeline(x)
//        replay(tx)
//    }
//}
