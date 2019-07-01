//
//  PDLazyListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//


public extension PDListRepository.Lazy {
    typealias Base = PDListRepository
    typealias Map<X> = PDLazyMapListRepository<Base,X>
    func map<X>(_ mfx: @escaping (Base.Element) -> X) -> Map<X> {
        return PDLazyMapListRepository<Base,X>(base: base, mfx: mfx)
    }
}

public struct PDLazyMapListRepository<Base,Element>:
PDListRepositoryProtocol where
Base: PDListRepositoryProtocol {
    let base: Base
    let mfx: (Base.Element) -> Element
}
public extension PDLazyMapListRepository {
    typealias Timeline = PDLazyMapTimeline<Base.Timeline,Step>
    typealias Step = PDListStep<Base.Snapshot>.Lazy.MapStep<Element>
    typealias Snapshot = LazyMapCollection<Base.Snapshot,Element>
    var timeline: Timeline {
        let mfx1 = mfx
        return Timeline(base: base.timeline, mfx: { s in s.lazyStep.map(mfx1) })
    }
    var latestOnly: PDLazyMapListRepository {
        return PDLazyMapListRepository(base: base.latestOnly, mfx: mfx)
    }
    func latest(since p: PDTimestamp) -> PDLazyMapListRepository? {
        guard let r = base.latest(since: p) else { return nil }
        return PDLazyMapListRepository(base: r, mfx: mfx)
    }
    var startIndex: Int { return base.startIndex }
    var endIndex: Int { return base.endIndex }
    subscript(_ i: Int) -> Element { return mfx(base[i]) }
}
