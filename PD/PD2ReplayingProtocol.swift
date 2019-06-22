//
//  PD2ReplayingProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

public protocol PD2ReplayingProtocol {
    associatedtype Snapshot: Collection
    typealias Timeline = PD2Timeline<Snapshot>

    /// Replays records in timeline automatically from matching time-point.
    ///
    /// This method find matching time-point in supplied timeline and re-apply
    /// changes since the time. If there's no matching time, this method
    /// crashes.
    ///
    mutating func replay(_: Timeline)

//    /// Replays records in timeline automatically from matching time-point.
//    ///
//    /// This method find matching time-point in supplied timeline and re-apply
//    /// changes since the time. If there's no matching time-point, this method
//    /// crashes unless `always == true`.
//    ///
//    /// - Parameter always:
//    ///     If set tot `true`, replay always continues to supplied timeline.
//    ///     If there's no matching time, this method "creates"
//    ///     a full replacement stepping to connect them smoothly.
//    ///     As a result, this always continues to the timeline,
//    ///     but resuling timeline can be different with original one.
//    ///
//    mutating func replay(_: Timeline, always: Bool)
}
//public enum PD2ReplayOption {
//    /// If there's no matching time-point,
//    /// just replace
//    case replace
//    case cancel
//}

