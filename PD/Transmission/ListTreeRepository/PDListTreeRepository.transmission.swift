//
//  PDListTreeRepository.transmission.swift
//  PD
//
//  Created by Henry on 2019/07/04.
//

import Foundation
import Tree

public extension PDListTreeRepository {
    /// Transmits latest collection state into target `r`.
    /// - This tries best to make contiguous transmission.
    /// - Keeps all original timestamps if transmission is contiguous.
    /// - Performs snapshot replacement if it's impossible.
    func transmit<X>(to r: inout PDListTreeRepository<X>, with mfx: (Value) -> X) {
        let t = r.timeline.steps.last?.new.time ?? .default
        if let tx = timeline.suffix(since: t) {
            // Timeline continuous.
            // Map and replay.
            for x in tx.steps {
                switch x.operation {
                case .removeSubtrees:
                    r.recordSubtreesRemoving(x.range, in: x.path, with: x.new.time)
                case .insertSubtrees:
                    let p = x.new
                    let s = p.snapshot
                    let c = x.path == [] ? s.collection : s[x.path].collection
                    let ts = c[x.range].map({ ListTree(value: mfx($0.value)) })
                    r.recordSubtreesInsertion(contentsOf: ts, at: x.range.lowerBound, in: x.path, with: p.time)
                case .setValues:
                    let p = x.new
                    let s = p.snapshot
                    let c = x.path == [] ? s.collection : s[x.path].collection
                    let vs = c[x.range].map({ mfx($0.value) })
                    r.recordValuesSetting(vs, at: x.range.lowerBound, in: x.path, with: p.time)
                }
            }
        }
        else {
            // Timeline discontinued.
            // Reset.
            let t = timeline.steps.last?.new.time ?? PDTimestamp()
            let s = latestSnapshot.map(mfx) as ListTreeStorage<X>
            r = PDListTreeRepository<X>()
            r.recordSubtreesInsertion(contentsOf: s.collection, at: 0, in: [], with: t)
        }
    }
}
