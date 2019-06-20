//
//  PDTreeTransmission.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

import Foundation

struct PDTreeTransmission {
    private(set) var transferredVersion = AnyHashable(PDIdentity())

    /// Maps changes from `source` to `target`.
    /// If source does not have consecutive change-set,
    /// target will be reset.
    mutating func map<From,To>(from source: PDTreeRepository<From>, into target: inout PDTreeRepository<To>, with transform: (From) -> To) where
        From: TreeProtocol,
        From.SubtreeCollection.Index == IndexPath.Element,
        To: MutableTreeProtocol,
        To.SubtreeCollection.Index == IndexPath.Element
    {
        if let news = source.timeline.latest(since: transferredVersion) {
            for step in news.steppins {
                for (idxp,_) in step.from.reversed() {
                    target.remove(at: idxp)
                }
                for (idxp,node) in step.to {
                    target.insert(transform(node), at: idxp)
                }
            }
            transferredVersion = news.versions.last ?? transferredVersion
        }
        else {
            precondition(
                !source.timeline.snapshots.isEmpty,
                "Source is empty. This function cannot be executed with empty source.")
            let v = source.timeline.snapshots.last!
            target.replace(at: [], with: transform(v))
            transferredVersion = source.timeline.versions.last!
        }
    }
}
