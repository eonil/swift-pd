//
//  PDLazyTimeline.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation

public struct PDLazyTimeline<Base> where Base: PDTimelineProtocol {
    var base: Base
}
public extension PDLazyTimeline {
    typealias Map<X> = PDLazyMapTimeline<Base,X> where X: PDTimelineStepProtocol
    func map<X>(_ mfx: @escaping (Base.Step) -> X) -> Map<X> where
    X: PDTimelineStepProtocol {
        return PDLazyMapTimeline(base: base, mfx: mfx)
    }
}

// MARK: Mapped
public struct PDLazyMapTimeline<Base,Step>: PDTimelineProtocol where
    Base: PDTimelineProtocol,
Step: PDTimelineStepProtocol {
    let base: Base
    let mfx: (Base.Step) -> Step
}
public extension PDLazyMapTimeline {
    func suffix(since v: PDTimestamp) -> PDLazyMapTimeline? {
        guard let x = base.suffix(since: v) else { return nil }
        return x.lazyTimeline.map(mfx)
    }
    func reversed() -> PDLazyMapTimeline {
        return base.lazyTimeline.map(mfx)
    }
}

// MARK: Mapped Stepping
public extension PDLazyMapTimeline {
    var steps: Steps { return Steps(base: base, mfx: mfx) }
    struct Steps: RandomAccessCollection {
        var base: Base
        var mfx: (Base.Step) -> Step
    }
}
public extension PDLazyMapTimeline.Steps {
    typealias Index = Base.Steps.Index
    var startIndex: Index {
        return base.steps.startIndex
    }
    var endIndex: Index {
        return base.steps.endIndex
    }
    subscript(_ i: Index) -> Step {
        return mfx(base.steps[i])
    }
}

