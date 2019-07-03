//
//  PDAnyTimeline.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public struct PDAnyTimeline<Step>: PDTimelineProtocol where
Step: PDTimelineStepProtocol {
    private let xs: PDAnyList<Step>
    private let getSuffix: (PDTimestamp) -> PDAnyTimeline?
    private let getReversed: () -> PDAnyTimeline
    public init<T>(_ s:T) where T: PDTimelineProtocol, T.Step == Step {
        xs = PDAnyList<Step>(s.steps)
        getSuffix = { s.suffix(since: $0).map({ PDAnyTimeline($0) }) }
        getReversed = { PDAnyTimeline(s.reversed()) }
    }
}
public extension PDAnyTimeline {
    typealias Time = PDTimestamp
    typealias Point = Step.Point
    typealias Snapshot = Step.Snapshot

    var steps: PDAnyList<Step> { return xs }
    func suffix(since v: PDTimestamp) -> PDAnyTimeline? {
        return getSuffix(v)
    }
    func reversed() -> PDAnyTimeline {
        return getReversed()
    }
}
