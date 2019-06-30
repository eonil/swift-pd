//
//  PDRepositoryProtocol.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDRepositoryProtocol {
    var lazy: PDLazy<Self> { return PDLazy(base: self) }
}

public extension PDLazy where Base: PDRepositoryProtocol {
    func map<Derived>(_ mfx: @escaping (Base.Step) -> Derived) -> PDLazyMappedRepository<Base,Derived> where
    Derived: PDTimelineStepProtocol {
        return PDLazyMappedRepository(base: base, mfx: mfx)
    }
}

public struct PDLazyMappedRepository<Base,Step>: PDRepositoryProtocol where
Base: PDRepositoryProtocol,
Step: PDTimelineStepProtocol {
    let base: Base
    let mfx: (Base.Step) -> Step
}
public extension PDLazyMappedRepository {
    var timeline: PDLazyMappedTimeline<Base.Timeline,Step> {
        return base.timeline.lazy.map(mfx)
    }
    var latestOnly: PDLazyMappedRepository {
        return base.latestOnly.lazy.map(mfx)
    }
}
