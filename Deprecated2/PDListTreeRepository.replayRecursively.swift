////
////  PDListTreeRepository.replayRecursively.swift
////  PD
////
////  Created by Henry on 2019/06/30.
////
//
//import Foundation
//
//protocol PDListTreeElementProtocol {
//    var state: State { get }
//    associatedtype State
//    var subrepository: PDListRepository<Self> { get }
//}
//
//extension PDListTreeRepository where Value: PDListTreeElementProtocol {
//    /// Initializes this repository to copy tree structures and values of supplied repository.
//    init(recursively r: PDListRepository<Value>) {
//        appendRecursively(r, in: [])
//    }
//    private mutating func appendRecursively(_ r: PDListRepository<Value>, in pp: IndexPath) {
//        for (i,v) in r.enumerated() {
//            let p = pp.appending(i)
//            insert(v, at: p)
//            let r1 = v.subrepository
//            appendRecursively(r1, in: p)
//        }
//    }
//
//    /// Replays supplied list repository and all of its sub-repositories.
//    ///
//    /// This function requires supplied repository is continuous from this repository.
//    ///
//    /// - Note:
//    ///     This effectively flattens nested list-repositories into single tree repository.
//    ///
//    ///
//    /// Continuity Validation
//    /// ---------------------
//    /// Nested list repositories have multiple timelines hat are recorded individually.
//    /// This can be considered as a multi-track recording.
//    ///
//    /// Here're how timestamps are recorded in nested list repositories.
//    ///
//    ///     -----------------------------
//    ///     lv.1    ab---fg----l--q
//    ///     -----------------------------
//    ///     lv.2      cde  h--k mn
//    ///     -----------------------------
//    ///     lv.3            ij
//    ///     -----------------------------
//    ///
//    /// Here `b-f`, `g-l`, `l-g`, `h-k` steppings are all update steppings
//    /// with sub-repository changes. Conceptually, changes in lower levels have
//    /// to be recorded as updates in upper levels.
//    ///
//    /// Therefore, replayed steppings always start and end with top-level
//    /// timestamps, therefore there will be no continuity issue.
//    ///
//    mutating func replayRecursively(_ lt: PDListRepository<Value>.Timeline, in pp: IndexPath) {
//        typealias ListTimeline = PDListRepository<Value>.Timeline
//        typealias ListStep = ListTimeline.Step
//        guard let lt1 = findStepsToReplay(in: lt) else {
//            fatalError()
//        }
//        for lx in lt1.steps {
//            switch lx.operation {
//            case .replace:
//                let x1 = timeline.steps.last
//                let t1 = x1?.new.time ?? PDTimestamp()
//                let t2 = PDTimestamp()
//                let s1 = x1?.new.snapshot ?? Snapshot()
//                var s2 = s1
//                for i in lx.range {
//                    let p = pp.appending(i)
//                    let v = lx.new.snapshot[i]
//                    s2[p] = v
//                    do {
//                        let lsr = v.subrepository
//                        lsr.
//                    }
//                }
//                let x2 = Step(
//                    operation: .setValues,
//                    path: pp,
//                    range: lx.range,
//                    old: Step.Point(time: t1, snapshot: s1),
//                    new: Step.Point(time: t2, snapshot: s2))
//                impl.record(x2)
//            case .remove:
//
//            case .insert:
//            }
//        }
//    }
//    private func findStepsToReplay(in x: PDListRepository<Value>.Timeline) -> PDListRepository<Value>.Timeline? {
//        guard let t = timeline.steps.last?.new.time else { return x.steps }
//        return x.suffix(since: t)
//    }
//}
