////
////  PDX2.swift
////  PD
////
////  Created by Henry on 2019/06/30.
////
//
//import Foundation
//import Tree
//
//struct PDX2<A> where
//A:PDListRepositoryProtocol {
//    private var latestTimestamps = ListTree<PDTimestamp>(value: defaultTimestamp)
//    private var targetStorage = B()
//    private func findNewSteps(_ r: A) -> A.Timeline? {
//        let t = latestTimestamps.value
//        guard t != defaultTimestamp else { return r.timeline }
//        return r.timeline.suffix(since: t)
//    }
//    private func insertRecursively(_ e:A.Element, at i:Int, in pp:IndexPath, with fx:(A.Element) -> A) {
//        
//    }
//
//    typealias B = PDListTreeRepository<A.Element>
//    init(_ a:A) {
//    }
//    /// - Parameter with:
//    ///     A function that provides sub-repository for each element in `r`.
//    mutating func replay(_ r: A, with fx: (A.Element) -> PDAnyListRepository<A.Element>) {
//        guard let tx = findNewSteps(r) else { fatalError() }
//        for x in tx.steps {
//            switch x.operation {
//            case .remove:
//                for i in x.range {
//                    targetStorage.remove(at: [i])
//                }
//            case .insert:
//                for i in x.range {
//                    let e = x.new.snapshot[i]
//                    targetStorage.insert(e, at: [i])
//                }
//            case .replace:
//                for i in x.range {
//                    let e = x.new.snapshot[i]
//                    targetStorage.setValue(e, at: [i])
//                }
//            }
//        }
//    }
//}
//
//private let defaultTimestamp = PDTimestamp()
