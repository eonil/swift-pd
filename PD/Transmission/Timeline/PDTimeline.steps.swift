//
//  PDTimeline.steps.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public extension PDTimeline {
    typealias Point = Step.Point
    var steps: Steps {
        return Steps(impl: impl)
    }
    struct Steps: RandomAccessCollection {
        private(set) var impl: PDList<Step>
    }
}
public extension PDTimeline.Steps {
    var startIndex: Int {
        return impl.startIndex
    }
    var endIndex: Int {
        return impl.endIndex
    }
    subscript(_ i: Int) -> Step {
        return impl[i]
    }
}
