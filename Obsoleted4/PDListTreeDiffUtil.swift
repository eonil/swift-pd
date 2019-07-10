////
////  PDListTreeDiffUtil.swift
////  PD
////
////  Created by Henry on 2019/06/29.
////
//
//import Foundation
//import DifferenceKit
//
//public extension PDListTreeRepository {
//    /// Replays differences from `a` to `b` on this repository.
//    /// - Note:
//    ///     Current implementation is using `DifferenceKit`.
//    ///     Future version can be migrated to Swift 5's `CollectionDifference` suppoer.
//    mutating func replayDifferences<C,K>(from a:C, to b:C, in pp: IndexPath, with kfx: @escaping (Value) -> K) where
//    C:RandomAccessCollection,
//    C:RangeReplaceableCollection,
//    C.Element == Value,
//    C.Index == Int,
//    K:Hashable {
//        let a1 = a.map({ PDDiffWrapping(val: $0, key: kfx) })
//        let b1 = b.map({ PDDiffWrapping(val: $0, key: kfx) })
//        let cs = StagedChangeset(source: a1, target: b1)
//        for c in cs {
//            for i in c.elementDeleted.lazy.map({ $0.element }).sorted().reversed() {
//                let p = pp.appending(i)
//                remove(at: p)
//            }
//            for i in c.elementInserted.lazy.map({ $0.element}).sorted() {
//                let p = pp.appending(i)
//                let v = b[i]
//                insert(v, at: p)
//            }
//        }
//    }
//}
//
//struct PDDiffWrapping<V,K>:
//Differentiable where
//K:Hashable {
//    var val:V
//    var key: (V) -> K
//    var differenceIdentifier:K {
//        let k = key(val)
//        return k
//    }
//    func isContentEqual(to source: PDDiffWrapping<V,K>) -> Bool {
//        return differenceIdentifier == source.differenceIdentifier
//    }
//}
////extension PDDiffWrapping where V:Equatable {
////    func isContentEqual(to source: PDDiffWrapping<V,K>) -> Bool {
////        return val == source.val
////    }
////}
//
