//
//  PDListRepository.replay.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public extension PDListRepository {
    mutating func replay<T>(_ tx: T) where T:PDTimelineProtocol, T.Step == Timeline.Step {
        guard !tx.steps.isEmpty else { return }
        precondition(timeline.steps.last?.new.time == tx.steps.first?.old.time)
        for x in tx.steps {
            record(x)
        }
    }
}
extension PDListRepository {
    /// Replay with mapping elements.
    /// This keeps timestamps as is.
    mutating func replay<R>(_ r:R, with mfx: (R.Element) -> Element) where
    R:PDListRepositoryProtocol {
        guard !r.timeline.steps.isEmpty else { return }
        precondition(timeline.steps.last?.new.time == r.timeline.steps.first?.old.time)
        for x in r.timeline.steps {
            guard !x.range.isEmpty else { continue }
            let x1 = timeline.steps.last
            let t1 = x1?.new.time ?? PDTimestamp()
            let t2 = PDTimestamp()
            let s1 = latestSnapshot
            var s2 = s1
            switch x.operation {
            case .remove:
                s2.removeSubrange(x.range)
                let x2 = Step(
                    operation: .remove,
                    range: x.range,
                    old: Step.Point(time: t1, snapshot: s1),
                    new: Step.Point(time: t2, snapshot: s2))
                record(x2)
            case .insert:
                let es = x.new.snapshot[x.range].map({ mfx($0) })
                s2.insert(contentsOf: es, at: x.range.lowerBound)
                let x2 = Step(
                    operation: .insert,
                    range: x.range,
                    old: Step.Point(time: t1, snapshot: s1),
                    new: Step.Point(time: t2, snapshot: s2))
                record(x2)
            case .replace:
                let es = x.new.snapshot[x.range].map({ mfx($0) })
                s2.replaceSubrange(x.range, with: es)
                let x2 = Step(
                    operation: .replace,
                    range: x.range,
                    old: Step.Point(time: t1, snapshot: s1),
                    new: Step.Point(time: t2, snapshot: s2))
                record(x2)
            }
        }
    }
}
