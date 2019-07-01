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
    public init() {}
}
public extension PDListTreeTransmission {
    typealias Target = PDListTreeRepository<Value>
    /// Replays changes in list into specific node in a list-tree.
    ///
    /// This automatically tracks and validates timestamps and
    /// inserts appropriate extra steps if needed.
    mutating func transit<R>(to r:R, in pp: IndexPath, with mfx: (R.Element) -> Value) where
    R:PDListRepositoryProtocol {
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
                target.recordUnconditionlly(x, in: pp, with: mfx)
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
                    contentsOf: s.map({ ListTree(value: mfx($0)) }),
                    at: s.startIndex,
                    in: pp,
                    with: x.old.time)
                // DO NOT replay steps.
            }
        }
    }
}
