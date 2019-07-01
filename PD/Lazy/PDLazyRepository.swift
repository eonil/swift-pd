////
////  PDLazyRepository.swift
////  PD
////
////  Created by Henry on 2019/06/30.
////
//
//public extension PDRepositoryProtocol {
//    /// Makes a lazily-evaluated repository instance.
//    /// See `PDLazyRepository` for details.
//    var lazyRepository: PDLazyRepository<Self> {
//        return PDLazyRepository(base: self)
//    }
//}
//
///// A lazily-evaluated repository.
/////
///// This is a placeholder type to derive more specialized lazy types.
///// See methods of this type for the variants.
//public struct PDLazyRepository<Base> where
//Base: PDRepositoryProtocol {
//    let base: Base
//}
//
//
//
//// MARK: Map
//public extension PDLazyRepository {
//    /// Makes a mapped repository with **step** mapping function.
//    func map<Derived>(_ mfx: @escaping (Base.Step) -> Derived) ->
//    PDLazyMappedRepository<Base,Derived> where
//    Derived: PDTimelineStepProtocol {
//        return PDLazyMappedRepository(base: base, mfx: mfx)
//    }
//}
///// A lazily mapped repository.
//public struct PDLazyMappedRepository<Base,Step>: PDRepositoryProtocol where
//Base: PDRepositoryProtocol,
//Step: PDTimelineStepProtocol {
//    let base: Base
//    let mfx: (Base.Step) -> Step
//}
//public extension PDLazyMappedRepository {
//    typealias Snapshot = Step.Snapshot
//    var timeline: PDLazyMappedTimeline<Base.Timeline,Step> {
//        return base.timeline.lazy.map(mfx)
//    }
//    var latestOnly: PDLazyMappedRepository {
//        return base.latestOnly.lazyRepository.map(mfx)
//    }
//}
//
//
//
//// MARK: PDListRepository Variants
//public extension PDLazyRepository where Base: PDListRepositoryProtocol {
//    /// Makes a lazily mapped repository with element mapping funciton.
//    /// You are supposed to use this method like this.
//    ///
//    ///     let r = PDListRepository<Int>()
//    ///     let r1 = r.lazy.map({ "\($0)" })
//    ///
//    /// Now you have `Int` to `Stirng` converting repository `r1`.
//    ///
//    func mapElements<X>(_ mfx: @escaping (Base.Snapshot.Element) -> X) ->
//    PDLazyMappedRepository<Base,Base.Step.Lazy.MapStep<X>> {
//        let r = map({ (_ s: Base.Step) -> Base.Step.Lazy.MapStep<X> in
//            s.lazyStep.map(mfx)
//        })
//        return r
//    }
//}
//
////public extension PDLazyMappedRepository where
////Base: PDListRepositoryProtocol,
////Base.Snapshot: RangeReplaceableCollection {
////    var latestSnapshot: Snapshot {
////        let s = base.timeline.steps.last?.new.snapshot ?? Base.Snapshot()
////        return mfx
////    }
////}
////
////extension PDLazyMappedRepository: RandomAccessCollection where
////Base: PDListRepositoryProtocol,
////Snapshot: RandomAccessCollection  {}
////
////public extension PDLazyMappedRepository where
////Base: PDListRepositoryProtocol,
////Snapshot: RandomAccessCollection  {
////    var latestSnapshot: Snapshot {
////        return timeline.steps.last?.new.snapshot ?? Snapshot()
////    }
////    var startIndex: Int { return latestSnapshot.startIndex }
////    var endIndex: Int { return latestSnapshot.endIndex }
////    subscript(_ i: Int) { return latestSnapshot[i] }
////}
////
//
//extension PDLazyMappedRepository: PDListRepositoryProtocol where
//Base: PDListRepositoryProtocol {
//    private var latestSnapshot: Snapshot? {
//        let s = base.timeline.steps.last?.new.snapshot
//        return mfx(s)
//    }
//    var startIndex: Int { return latestSnapshot?.startIndex ?? 0 }
//    var endIndex: Int { return latestSnapshot?.endIndex ?? 0 }
//    subscript(_ i: Int) -> Base.Element {
//        guard let s = latestSnapshot else { fatalError() }
//        return s[i]
//    }
//}
