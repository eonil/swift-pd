//
//  PDListTreeRepository.record.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation
import Tree

extension PDListTreeRepository {
    /// Records a list-step `x` in collection at location `pp` with mapping `mfx`.
    /// `[]` means root collection.
    /// This keeps original timestamps.
    /// New steps will be recorded with original timestamps.
    ///
    /// Replacing an element replaces only values and does not touch
    /// descendants. You have to manually insert/remove each node
    /// to modify descendants.
    ///
    /// - Warning:
    ///     This records a new step WIHTOUT time-point validation.
    mutating func recordUnconditionally<S>(_ x: PDListStep<S>, in pp: IndexPath, with mfx: (S.Element) -> Value) {
        let t = x.new.time
        switch x.operation {
        case .remove:
            recordSubtreesRemoving(x.range, in: pp, with: t)
        case .insert:
            let es = x.new.snapshot[x.range]
            let ts = es.map({ ListTree(value: mfx($0)) })
            let i = x.range.lowerBound
            recordSubtreesInsertion(contentsOf: ts, at: i, in: pp, with: t)
        case .replace:
            let es = x.new.snapshot[x.range].map(mfx)
            let i = x.range.lowerBound
            recordValuesSetting(es, at: i, in: pp, with: t)
        }
    }
    mutating func recordUnconditionally<S>(_ x: PDListStep<S>, in pp: IndexPath) where S.Element == Value {
        recordUnconditionally(x, in: pp, with: {$0})
    }
}
