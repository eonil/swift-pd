//
//  PDListTreeRepository.transit.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation

public extension PDListTreeRepository {
    /// Performs `transit` with element mapping on-the-fly.
    /// This keeps all timestamps as are.
    @available(*, deprecated: 0, message: "This method cannot provide timestamp validation. Use `PDListTreeTransmission` type instead of.")
    mutating func transit<R>(to r:R, in pp: IndexPath, with mfx: (R.Element) -> Value) where
    R:PDListRepositoryProtocol {
        guard !r.timeline.steps.isEmpty else { return }
        if let tx = r.timeline.suffix(sinceLastPointOf: timeline) {
            // There's an intersection point.
            // Replay from there.
            for x in tx.steps {
                recordUnconditionally(x, in: pp, with: mfx)
            }
        }
        else {
            // No intersection point.
            // Make them continuous.
            // And replay all.
            let xs = wholeSnapshotReplacementSteps(to: r, in: pp, with: mfx)
            for x in xs {
                replay(x)
            }
            for x in r.timeline.steps {
                recordUnconditionally(x, in: pp, with: mfx)
            }
        }
    }
}






private extension PDTimelineProtocol {
    func suffix<T>(sinceLastPointOf tx:T) -> Self? where T:PDTimelineProtocol {
        guard let t = tx.steps.last?.new.time else { return nil }
        return suffix(since: t)
    }
}

private extension PDListTreeRepository {
    /// This involves actual mapping.
    func wholeSnapshotReplacementSteps<R>(to r:R, in pp: IndexPath, with mfx: (R.Element) -> Value) -> [Step] where
    R:PDListRepositoryProtocol {
        typealias P = Step.Point
        assert(!r.timeline.steps.isEmpty)
        let rp3 = r.timeline.steps.first!.old
        let rs3 = rp3.snapshot
        let rs3r = rs3.startIndex..<rs3.endIndex

        let p1 = timeline.steps.last?.new ?? P(time: PDTimestamp(), snapshot: Snapshot())
        let s1 = p1.snapshot
        let s1c = pp.count == 0 ? s1.collection : s1[pp].collection
        let s1r = s1c.startIndex..<s1c.endIndex
        var s2 = s1
        for i in s1r.lazy.reversed() {
            let p = pp.appending(i)
            s2.remove(at: p)
        }
        var s3 = s2
        let s3r = rs3r
        for i in s3r {
            let e = rs3[i]
            let v = mfx(e)
            let p = pp.appending(i)
            s3.insert(v, at: p)
        }
        let p2 = P(time: PDTimestamp(), snapshot: Snapshot())
        let p3 = P(time: rp3.time, snapshot: s3)
        let x1 = Step(
            operation: .removeSubtrees,
            path: pp,
            range: s1r,
            old: p1,
            new: p2)
        let x2 = Step(
            operation: .insertSubtrees,
            path: pp,
            range: s3r,
            old: p2,
            new: p3)
        return [x1,x2]
    }
}
