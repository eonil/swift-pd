//
//  PDListRepository.transit.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public extension PDListRepository {
    /// Performs transitions to become latest state of target repository `r`.
    ///
    /// Replay vs. Transit
    /// ------------------
    /// `replay` method just copies steps since specific time-point.
    /// Replay fails if there's no intersection like these cases.
    /// - This repository is empty
    /// - Target repository is not continous from this repository.
    ///
    /// `transit` method always becomes target snapshot
    /// (latest state of target repository) by making a new artificial step
    /// that replaces whole snapshot.
    /// `transit` tries and performs `replay` first, and adds
    /// replacement if target is not replayable.
    mutating func transit<R>(to r:R) where
    R:PDListRepositoryProtocol,
    R.Timeline.Step.Snapshot == Timeline.Step.Snapshot {
        guard !r.timeline.steps.isEmpty else { return }
        if let tx = r.timeline.suffix(sinceLastPointOf: timeline) {
            // There's an intersection point.
            // Replay from there.
            replay(tx)
        }
        else {
            // No intersection point.
            // Make them continuous.
            // And replay all.
            let xs = wholeSnapshotReplacementSteps(to: r)
            for x in xs {
                record(x)
            }
            replay(r.timeline)
        }
    }
    /// Performs `transit` with element mapping on-the-fly.
    mutating func transit<R>(to r:R, with mfx: (R.Element) -> Element) where
    R:PDListRepositoryProtocol {
        guard !r.timeline.steps.isEmpty else { return }
        if let tx = r.timeline.suffix(sinceLastPointOf: timeline) {
            // There's an intersection point.
            // Replay from there.
            let r1 = r.latest(since: tx.steps.first!.old.time)!
            replay(r1, with: mfx)
        }
        else {
            // No intersection point.
            // Make them continuous.
            // And replay all.
            let xs = wholeSnapshotReplacementSteps(to: r, with: mfx)
            for x in xs {
                record(x)
            }
            replay(r, with: mfx)
        }
    }
}






private extension PDTimelineProtocol {
    func suffix<T>(sinceLastPointOf tx:T) -> Self? where T:PDTimelineProtocol {
        guard let t = tx.steps.last?.new.time else { return nil }
        return suffix(since: t)
    }
}

private extension PDListRepository {
    func wholeSnapshotReplacementSteps<R>(to r:R) -> [Step] where
    R:PDListRepositoryProtocol,
    R.Timeline.Step == Timeline.Step {
        typealias P = Step.Point
        assert(!r.timeline.steps.isEmpty)
        let p1 = timeline.steps.last?.new ?? P(time: PDTimestamp(), snapshot: Snapshot())
        let p2 = P(time: PDTimestamp(), snapshot: Snapshot())
        let p3 = r.timeline.steps.first!.old
        let s1 = p1.snapshot
        let s3 = p3.snapshot
        let x1 = Step(
            operation: .remove,
            range: s1.startIndex..<s1.endIndex,
            old: p1,
            new: p2)
        let x2 = Step(
            operation: .insert,
            range: s3.startIndex..<s3.endIndex,
            old: p2,
            new: p3)
        return [x1,x2]
    }
    /// This involves actual mapping.
    func wholeSnapshotReplacementSteps<R>(to r:R, with mfx: (R.Element) -> Element) -> [Step] where
    R:PDListRepositoryProtocol {
        typealias P = Step.Point
        assert(!r.timeline.steps.isEmpty)
        let p1 = timeline.steps.last?.new ?? P(time: PDTimestamp(), snapshot: Snapshot())
        let p2 = P(time: PDTimestamp(), snapshot: Snapshot())
        let p3 = r.timeline.steps.first!.old
        let s1 = p1.snapshot
        let s3 = p3.snapshot
        let x1 = Step(
            operation: .remove,
            range: s1.startIndex..<s1.endIndex,
            old: p1,
            new: p2)
        let x2 = Step(
            operation: .insert,
            range: s3.startIndex..<s3.endIndex,
            old: p2,
            new: P(time: p3.time, snapshot: Snapshot(p3.snapshot.map(mfx))))
        return [x1,x2]
    }
}
