//
//  PDListRepository.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDListRepository {
    typealias LazyMapSnapshot<X> = LazyMapCollection<Snapshot,X>
    typealias LazyMapStep<X> = PDListStep<LazyMapSnapshot<X>>
    typealias LazyMapRepository<X> = PDLazyMappedRepository<PDListRepository,LazyMapStep<X>>
    func lazyMap<X>(_ mfx: @escaping (Element) -> X) -> LazyMapRepository<X> {
        return lazyRepository.map({ (_ s: Timeline.Step) -> LazyMapStep<X> in
            return s.lazyStep.map(mfx)
        })
    }
}

