//
//  PDListTreeTransmission.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation
import Tree

/// Automatic change-set transmission into list-tree from tree of multiple lists.
public struct PDListTreeTransmission<Value> {
    /// Stores latest source point timestamps.
    private var timestampTree = ListTree(value: nil as PDTimestamp?)
    private(set) var target = Target()
    public init() {

    }
}
public extension PDListTreeTransmission {
    typealias Target = PDListTreeRepository<Value>
//    mutating func transit<S>(_ x:PDListStep<S>, in pp: IndexPath) where
//    S.Element == Value {
//        let t = timestampTree[pp].value
//        if let t = t, x.new.time == t {
//            // Matches time.
//            // Replay it.
//            var latestTime = t
//            assert(x.old.time == latestTime)
//            // Update timestamp tree.
//            assert(x.old.snapshot.count == timestampTree[pp].collection.count)
//            switch x.operation {
//            case .remove:
//                timestampTree.removeSubrange(x.range, in: pp)
//            case .insert:
//                let es = repeatElement(nil as PDTimestamp?, count: x.range.count)
//                let ts = es.map({ ListTree(value: $0 )})
//                timestampTree.insert(contentsOf: ts, at: x.range.lowerBound, in: pp)
//            case .replace:
//                for i in x.range {
//                    let p = pp.appending(i)
//                    timestampTree[p].value = nil
//                }
//            }
//            target.recordUnconditionally(x, in: pp, with: {$0})
//            timestampTree[pp].value = x.new.time
//        }
//        else {
//            // No intersection.
//            // Reset to source state.
//            do {
//                // Add remove-all step.
//                let tc = timestampTree[pp].collection
//                let tr = 0..<tc.count
//                timestampTree.removeSubrange(tr, in: pp)
//                let ec = pp.count == 0 ? target.collection : target[pp].collection
//                let er = 0..<ec.count
//                assert(tr == er)
//                target.recordSubtreesRemoving(er, in: pp, with: PDTimestamp())
//            }
//            do {
//                // Add insert-all step.
//                let s = x.new.snapshot
//                let n = s.count
//                let ts = repeatElement(ListTree(value: nil as PDTimestamp?), count: n)
//                assert(timestampTree[pp].collection.count == 0)
//                timestampTree[pp].value = x.new.time
//                timestampTree.insert(contentsOf: ts, at: 0, in: pp)
//                assert(timestampTree[pp].collection.count == s.count)
//                target.recordSubtreesInsertion(
//                    contentsOf: s.map({ ListTree(value: $0) }),
//                    at: s.startIndex,
//                    in: pp,
//                    with: x.old.time)
//                // DO NOT replay steps.
//                // They're already been applied.
//            }
//            // Now target node is transformed into source list.
//            // Update descendants recursively.
//            do {
//                let s = x.new.snapshot
//                let c = s.count
//                for i in 0..<c {
//                    let e = s[i]
//                    if let r1 = subrepfx(e) {
//                        let p = pp.appending(i)
//                        transit(to: r1, in: p, with: subrepfx)
//                    }
//                }
//            }
//        }
//    }
    /// Replays changes in list into specific node in a list-tree.
    ///
    /// This automatically tracks and validates timestamps and
    /// inserts appropriate extra steps if needed.
    ///
    /// - Parameter with:
    ///     A function that resolves sub-repository from source element.
    mutating func transit<R>(to r:R, in pp: IndexPath, with subrepfx: (R.Element) -> R? = {_ in nil}) where
    R:PDListRepositoryProtocol,
    R.Element == Value {
        transit1(to: r, in: pp, with: subrepfx)
    }
    /// Replays changes in list into specific node in a list-tree.
    ///
    /// This automatically tracks and validates timestamps and
    /// inserts appropriate extra steps if needed.
    ///
    /// - Parameter with:
    ///     A function that resolves sub-repository from source element.
    private mutating func transit1<R,R1>(to r:R, in pp: IndexPath, with subrepfx: (R.Element) -> R1? = {_ in nil}) where
    R:PDListRepositoryProtocol,
    R.Element == Value,
    R1:PDListRepositoryProtocol,
    R1.Element == Value {
        guard !r.timeline.steps.isEmpty else { return }
        let t = timestampTree[pp].value
        if let t = t, let tx = r.timeline.suffix(since: t) {
            // Intersection point has been found.
            // Replay from there.
            var latestTime = t
            for x in tx.steps {
                assert(x.old.time == latestTime)
                // Update timestamp tree.
                assert(x.old.snapshot.count == timestampTree[pp].collection.count)
                switch x.operation {
                case .remove:
                    timestampTree.removeSubrange(x.range, in: pp)
                case .insert:
                    let es = repeatElement(nil as PDTimestamp?, count: x.range.count)
                    let ts = es.map({ ListTree(value: $0 )})
                    timestampTree.insert(contentsOf: ts, at: x.range.lowerBound, in: pp)
                case .replace:
                    for i in x.range {
                        let p = pp.appending(i)
                        timestampTree[p].value = nil
                    }
                }

                target.recordUnconditionally(x, in: pp, with: {$0})
                latestTime = x.new.time
            }
            timestampTree[pp].value = latestTime
        }
        else {
            // No intersection.
            // Reset to source state.
            if !target.timeline.steps.isEmpty {
                // Add remove-all step.
                let tc = timestampTree[pp].collection
                let tr = 0..<tc.count
                timestampTree.removeSubrange(tr, in: pp)
                let ec = pp.count == 0 ? target.collection : target[pp].collection
                let er = 0..<ec.count
                assert(tr == er)
                target.recordSubtreesRemoving(er, in: pp, with: PDTimestamp())
            }
            do {
                // Add insert-all step.
                let x = r.timeline.steps.last!
                let s = x.new.snapshot
                let n = s.count
                let ts = repeatElement(ListTree(value: nil as PDTimestamp?), count: n)
                assert(timestampTree[pp].collection.count == 0)
                timestampTree[pp].value = x.new.time
                timestampTree.insert(contentsOf: ts, at: 0, in: pp)
                assert(timestampTree[pp].collection.count == s.count)
                target.recordSubtreesInsertion(
                    contentsOf: s.map({ ListTree(value: $0) }),
                    at: s.startIndex,
                    in: pp,
                    with: x.old.time)
                // DO NOT replay steps.
                // They're already been applied.
            }
        }
        // Now target node is transformed into source list.
        // Update descendants recursively.
        do {
            let s = r.timeline.steps.last!.new.snapshot
            let c = s.count
            for i in 0..<c {
                let e = s[i]
                if let r1 = subrepfx(e) {
                    let p = pp.appending(i)
                    transit(to: r1, in: p, with: subrepfx)
                }
            }
        }
    }
}

//public protocol PDListTreeTransmissive {
//    var subrepository: SubRepository? { get }
//    associatedtype Value
//    associatedtype SubRepository: PDListRepositoryProtocol where
//        SubRepository.Element == Self
//}
//
//private struct PDTX<R>: PDListTreeTransmissive where
//R: PDListRepositoryProtocol,
//R.Element: PDListTreeTransmissive {
//    private let elem:R.Element
//    private let subrep: (E) -> R?
//    init(_ e:R.Element, _ rfx: @escaping (E) -> R?) {
//        elem = e
//        subrep = rfx
//    }
//    var value:V { return elem }
//    var subrepository: R? { return subrep(elem) }
//}
