//
//  PDListStepPoint.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public struct PDListStepPoint<Snapshot>:
PDTimelineStepPointProtocol where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int {
    public var time: PDTimestamp
    public var snapshot: Snapshot
}
