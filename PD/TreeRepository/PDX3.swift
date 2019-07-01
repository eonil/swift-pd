//
//  PDX3.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation
import Tree

public struct PDX3<Value> {
    /// Stores latest source point timestamps.
    private var timestampTree = ListTree<PDTimestamp>(value: PDTimestamp())
    private(set) var target = Target()
    typealias Target = PDListTreeRepository<Value>

    init() {
    }
    mutating func transit<R>(to r:R, in pp: IndexPath, with mfx: (R.Element) -> Value) where
    R:PDListRepositoryProtocol,
    R.Element == Value {
        guard !r.timeline.steps.isEmpty else { return }
        let t = timestampTree[pp].value
        if let tx = r.timeline.suffix(since: t) {
            // Intersection point has been found.
            // Replay from there.
            var latestTime = t
            for x in tx.steps {
                assert(x.old.time == latestTime)
                target.record(x, in: pp, with: mfx)
                latestTime = x.new.time
            }
            timestampTree[pp].value = latestTime
        }
        else {
            // No intersection.
            // Reset to source state.
            if !target.timeline.steps.isEmpty {
                // Add remove-all step.
                let c = target[pp].collection
                let r = c.startIndex..<c.endIndex
                target.recordSubtreesRemoving(r, in: pp, with: PDTimestamp())
            }
            do {
                // Add insert-all step.
                let x = r.timeline.steps.first!
                let s = x.old.snapshot
                target.recordSubtreesInsertion(
                    contentsOf: s.map({ ListTree(value: $0) }),
                    at: s.startIndex,
                    in: pp,
                    with: x.old.time)
            }
            var latestTime = t
            for x in r.timeline.steps {
                target.record(x, in: pp, with: mfx)
                latestTime = x.new.time
            }
            timestampTree[pp].value = latestTime
        }
    }
}
