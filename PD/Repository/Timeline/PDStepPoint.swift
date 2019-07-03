//
//  PDStepPoint.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

public struct PDStepPoint<Snapshot>:
PDTimelineStepPointProtocol,
CustomReflectable where
Snapshot: Collection {
    public var time: PDTimestamp
    public var snapshot: Snapshot
}
public extension PDStepPoint {
    var customMirror: Mirror {
        return Mirror(self, children: [
            "time": time,
            "snapshot": Array(snapshot)])
    }
}

