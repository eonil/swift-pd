//
//  PDTimelineStepPoint.swift
//  PD
//
//  Created by Henry on 2019/06/27.
//

public struct PDTimelineStepPoint<Snapshot>: PDTimelineStepPointProtocol {
    public var time: PDTimestamp
    public var snapshot: Snapshot
}
