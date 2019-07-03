//
//  PDAnyListRepository.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public struct PDAnyListRepository<Element>:
PDListRepositoryProtocol,
RandomAccessCollection {
    private let tx: Timeline
    private let getLatestOnly: () -> PDAnyListRepository
    private let latestSince: (PDTimestamp) -> PDAnyListRepository<Element>?
    var latestSnapshot: Snapshot? { return timeline.steps.last?.new.snapshot }
    public init<R>(_ r:R) where
    R:PDListRepositoryProtocol,
    R.Timeline.Snapshot.Element == Element {
        let tx1 = r.timeline.lazyTimeline.map({ (_ tx: PDListStep<R.Timeline.Snapshot>) -> PDListStep<PDAnyList<R.Element>> in
            return tx.mapAnyLazyElements({$0})
        })
        tx = PDAnyTimeline<Step>(tx1)
        getLatestOnly = { PDAnyListRepository(r.latestOnly) }
        latestSince = {
            guard let r1 = r.latest(since: $0) else { return nil }
            return PDAnyListRepository(r1)
        }
    }
}
public extension PDAnyListRepository {
    typealias Timeline = PDAnyTimeline<Step>
    typealias Step = PDListStep<Snapshot>
    typealias Snapshot = PDAnyList<Element>
    var timeline: Timeline { return tx }
    var latestOnly: PDAnyListRepository { return getLatestOnly() }
    func latest(since p: PDTimestamp) -> PDAnyListRepository<Element>? {
        return latestSince(p)
    }
}
public extension PDAnyListRepository {
    typealias Index = Int
    var startIndex: Int { return latestSnapshot?.startIndex ?? 0 }
    var endIndex: Int { return latestSnapshot?.endIndex ?? 0 }
    subscript(_ i:Int) -> Element {
        guard let s = latestSnapshot else { fatalError() }
        return s[i]
    }
}
