//
//  PDLazyRepository.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDRepositoryProtocol {
    /// Makes a lazily-evaluated repository instance.
    /// See `PDLazyRepository` for details.
    var lazyRepository: PDLazyRepository<Self> {
        return PDLazyRepository(base: self)
    }
}

/// A lazily-evaluated repository.
///
/// This is a placeholder type to derive more specialized lazy types.
/// See methods of this type for the variants.
public struct PDLazyRepository<Base> where
Base: PDRepositoryProtocol {
    let base: Base
}



// MARK: Map
public extension PDLazyRepository {
    /// Makes a mapped repository with **step** mapping function.
    func map<Derived>(_ mfx: @escaping (Base.Step) -> Derived) ->
    PDLazyMappedRepository<Base,Derived> where
    Derived: PDTimelineStepProtocol {
        return PDLazyMappedRepository(base: base, mfx: mfx)
    }
}
/// A lazily mapped repository.
public struct PDLazyMappedRepository<Base,Step>: PDRepositoryProtocol where
Base: PDRepositoryProtocol,
Step: PDTimelineStepProtocol {
    let base: Base
    let mfx: (Base.Step) -> Step
}
public extension PDLazyMappedRepository {
    typealias Snapshot = Step.Snapshot
    var timeline: PDLazyMappedTimeline<Base.Timeline,Step> {
        return base.timeline.lazy.map(mfx)
    }
    var latestOnly: PDLazyMappedRepository {
        return base.latestOnly.lazyRepository.map(mfx)
    }
}



// MARK: PDListRepository Variants
public extension PDLazyRepository where Base: PDListRepositoryProtocol {
    /// Makes a lazily mapped repository with element mapping funciton.
    /// You are supposed to use this method like this.
    ///
    ///     let r = PDListRepository<Int>()
    ///     let r1 = r.lazy.map({ "\($0)" })
    ///
    /// Now you have `Int` to `Stirng` converting repository `r1`.
    ///
    func map<X>(_ mfx: @escaping (Base.Snapshot.Element) -> X) ->
    PDLazyMappedRepository<Base,Base.Step.Lazy.MapStep<X>> {
        let r = map({ (_ s: Base.Step) -> Base.Step.Lazy.MapStep<X> in
            s.lazyStep.map(mfx)
        })
        return r
    }
}
