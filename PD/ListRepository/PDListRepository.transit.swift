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
        guard let t = timeline.steps.last?.new.time else {
            // This repository is empty.
            recordWholeSnapshotReplacement(to: r)
            return
        }
        guard let tx = r.timeline.suffix(since: t) else {
            // No intersection point.
            recordWholeSnapshotReplacement(to: r)
            return
        }
        replay(tx)
    }
    /// Performs `transit` with element mapping on-the-fly.
    mutating func transit<R>(to r:R, with mfx: (R.Element) -> Element) where
    R:PDListRepositoryProtocol {
        // Exit if supplied timeline is empty so no-op.
        guard let x2 = r.timeline.steps.first else { return }
        let x1 = timeline.steps.last
        guard x1?.isContinuous(to: x2) ?? false else {
            // Make them continuous.
            recordWholeSnapshotReplacement(to: r, with: mfx)
            return
        }
        // Now both timelines are not empty and continuous.
        replay(r, with: mfx)
    }
}








private extension PDListRepository {
    mutating func recordWholeSnapshotReplacement<R>(to r:R) where
    R:PDListRepositoryProtocol,
    R.Timeline.Step == Timeline.Step {
        typealias P = Step.Point
        assert(!r.timeline.steps.isEmpty)
        let p1 = timeline.steps.last
        let p2 = r.timeline.steps.first!
        let t1 = p1?.new.time ?? PDTimestamp()
        let t2 = p2.old.time
        let s1 = p1?.new.snapshot ?? Snapshot()
        let s2 = p2.old.snapshot
        let x = Step(
            operation: .replace,
            range: s1.startIndex..<s1.endIndex,
            old: P(time: t1, snapshot: s1),
            new: P(time: t2, snapshot: s2))
        record(x)
    }
    /// This involves actual mapping.
    mutating func recordWholeSnapshotReplacement<R>(to r:R, with mfx: (R.Element) -> Element) where
    R:PDListRepositoryProtocol {
        typealias P = Step.Point
        assert(!r.timeline.steps.isEmpty)
        let p1 = timeline.steps.last
        let p2 = r.timeline.steps.first!
        let t1 = p1?.new.time ?? PDTimestamp()
        let t2 = p2.old.time
        let s1 = p1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.replaceSubrange(s1.startIndex..<s1.endIndex, with: p2.old.snapshot.map(mfx))
        let x = Step(
            operation: .replace,
            range: s1.startIndex..<s1.endIndex,
            old: P(time: t1, snapshot: s1),
            new: P(time: t2, snapshot: s2))
        record(x)
    }
}
