//
//  PDListStepPoint.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public struct PDListStepPoint<Snapshot>:
PDTimelineStepPointProtocol,
CustomReflectable where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int {
    public var time: PDTimestamp
    public var snapshot: Snapshot
}
public extension PDListStepPoint {
    var customMirror: Mirror {
        return Mirror(self, children: [
            "time": time,
            "snapshot": Array(snapshot)])
    }
}
