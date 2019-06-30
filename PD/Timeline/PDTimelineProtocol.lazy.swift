//
//  PDTimelineProtocol.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

import Foundation

public extension PDTimelineProtocol {
    var lazy: PDLazy<Self> { return PDLazy(base: self) }
}
public extension PDLazy where Base: PDTimelineProtocol {
    func map<Derived>(_ mfx: @escaping (Base.Step) -> Derived) -> PDLazyMappedTimeline<Base,Derived> where
    Derived: PDTimelineStepProtocol {
        return PDLazyMappedTimeline(base: base, mfx: mfx)
    }
}

// MARK: Mapped
public struct PDLazyMappedTimeline<Base,Step>: PDTimelineProtocol where
Base: PDTimelineProtocol,
Step: PDTimelineStepProtocol {
    let base: Base
    let mfx: (Base.Step) -> Step
}
public extension PDLazyMappedTimeline {
    func suffix(since v: PDTimestamp) -> PDLazyMappedTimeline? {
        guard let x = base.suffix(since: v) else { return nil }
        return x.lazy.map(mfx)
    }
    func reversed() -> PDLazyMappedTimeline {
        return base.lazy.map(mfx)
    }
}

// MARK: Mapped Stepping
public extension PDLazyMappedTimeline {
    var steps: Steps { return Steps(base: base, mfx: mfx) }
    struct Steps: RandomAccessCollection {
        var base: Base
        var mfx: (Base.Step) -> Step
    }
}
public extension PDLazyMappedTimeline.Steps {
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

