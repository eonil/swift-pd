////
////  PDAnyListRepository.swift
////  PD
////
////  Created by Henry on 2019/07/01.
////
//
//public struct PDAnyListRepository<Element>:
//PDListRepositoryProtocol,
//RandomAccessCollection {
//    private let tx: Timeline
//    private let getLatestOnly: () -> PDAnyListRepository
//    var latestSnapshot: Snapshot? { return timeline.steps.last?.new.snapshot }
//    public init<R>(_ r:R) where
//    R:PDListRepositoryProtocol,
//    R.Timeline.Snapshot.Element == Element {
//        tx = PDAnyTimeline(r.timeline)
//        getLatestOnly = { PDAnyListRepository(r.latestOnly) }
//    }
//}
//public extension PDAnyListRepository {
//    typealias Timeline = PDAnyTimeline<Step>
//    typealias Step = PDListStep<Snapshot>
//    typealias Snapshot = PDAnyList<Element>
//    var timeline: Timeline { return tx }
//    var latestOnly: PDAnyListRepository { return getLatestOnly() }
//}
//public extension PDAnyListRepository {
//    typealias Index = Int
//    var startIndex: Int { return latestSnapshot?.startIndex ?? 0 }
//    var endIndex: Int { return latestSnapshot?.endIndex ?? 0 }
//    subscript(_ i:Int) -> Element {
//        guard let s = latestSnapshot else { fatalError() }
//        return s[i]
//    }
//}
