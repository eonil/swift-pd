//
//  PDListStep.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public struct PDListStep<Snapshot>: PDTimelineStepProtocol {
    public var old: Point
    public var new: Point
    public func reversed() -> PDListStep {
        return PDListStep(old: new, new: old)
    }
    public struct Point: PDTimelineStepPointProtocol {
        public var time: PDTimestamp
        public var snapshot: Snapshot
        /// Edited range at the point in the step.
        public var range: Range<Int>
    }
}
