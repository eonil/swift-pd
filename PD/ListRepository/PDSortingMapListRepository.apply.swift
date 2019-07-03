//
//  PDSortingMapListRepository.apply.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

public extension PDSortingMapListRepository {
    mutating func apply<R>(_ r:R) where
    R:PDListRepositoryProtocol,
    R.Snapshot.Index == Int,
    R.Snapshot.Element == Element {
        for x in r.timeline.steps {
            apply(x)
        }
    }
    mutating func apply<S>(_ x: PDListStep<S>, allowsDuplicatedOperations: Bool = false) where
    S:RandomAccessCollection,
    S.Index == Int,
    S.Element == Element {
        switch x.operation {
        case .remove:
            for i in x.range {
                let e = x.old.snapshot[i]
                let k = e.key
                recordRemoveStep(for: k, with: PDTimestamp())
            }
        case .insert:
            for i in x.range {
                let e = x.new.snapshot[i]
                let k = e.key
                let v = e.value
                recordInsertionStep(v, for: k, with: PDTimestamp())
            }
        case .replace:
            for i in x.range {
                let e = x.new.snapshot[i]
                let k = e.key
                let v = e.value
                recordReplacementStep(v, for: k, with: PDTimestamp())
            }
        }
    }
}
