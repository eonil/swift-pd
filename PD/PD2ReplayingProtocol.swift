//
//  PD2ReplayingProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

public protocol PD2ReplayingProtocol {
    associatedtype Timeline: PD2TimelineProtocol

    /// Replays records in timeline automatically from matching version.
    ///
    /// This method find matching version in supplied timeline and re-apply
    /// changes since the version. If there's no matching version, this method
    /// is no-op.
    ///
    mutating func replay(_: Timeline)
}

