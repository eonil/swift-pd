//
//  PDOrderedMapTreeStep.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/27.
//

import Tree
public extension PDOrderedMapTreeStep {
    typealias LazyValueMapped<Derived> = PDOrderedMapTreeStep<LazyValueMappedTree<Snapshot,Derived>>
    func lazyMapValues<Derived>(_ fx: @escaping (Snapshot.Value) -> Derived) -> LazyValueMapped<Derived> {
        switch self {
        case let .values(a,b,ks):
            let as1 = a.snapshot.lazyTree.mapValues(fx)
            let bs1 = b.snapshot.lazyTree.mapValues(fx)
            let a1 = (a.time,as1)
            let b1 = (b.time,bs1)
            return LazyValueMapped.values(from: a1, to: b1, at: ks)
        case let .subtrees(a,b,pk):
            let as1 = a.snapshot.lazyTree.mapValues(fx)
            let bs1 = b.snapshot.lazyTree.mapValues(fx)
            let a1 = (a.time, as1, a.range)
            let b1 = (b.time, bs1, b.range)
            return LazyValueMapped.subtrees(from: a1, to: b1, in: pk)
        }
    }
}
