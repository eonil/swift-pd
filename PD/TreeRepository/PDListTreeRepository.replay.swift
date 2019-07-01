//
//  PDListTreeRepository.replay.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation
import Tree

public extension PDListTreeRepository {
    /// Replays a list-step `x` in collection at location `pp` with mapping `mfx`.
    /// `[]` means root collection.
    /// This keeps original timestamps.
    /// New steps will be recorded with original timestamps.
    mutating func replay<S>(_ x: PDListStep<S>, in pp: IndexPath, with mfx: (S.Element) -> Value) {
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
}
