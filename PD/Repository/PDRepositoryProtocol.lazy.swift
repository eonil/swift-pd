//
//  PDRepositoryProtocol.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDRepositoryProtocol {
    var lazyRepository: PDLazyRepository<Self> {
        return PDLazyRepository(base: self)
    }
}

public struct PDLazyRepository<Base> where Base: PDRepositoryProtocol {
    let base: Base
}

public extension PDLazyRepository {
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
        return base.latestOnly.lazyRepository.map(mfx)
    }
}
