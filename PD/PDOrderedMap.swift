////
////  PDOrderedMap.swift
////  PD
////
////  Created by Henry on 2019/06/25.
////
//
//import Foundation
//
//public struct PDOrderedMap<Key,Value> where Key: Comparable {
//    private(set) var stateMap = PDMap<Key,Value>()
//    private(set) var orderingList = PDList<Key>()
//    public init() {}
//}
//public extension PDOrderedMap {
//    typealias Element = (key: Key, value: Value)
//    func index(for k: Key) -> Int? {
//        return orderingList.index(of: k)
//    }
//    subscript(key: Key) -> Value {
//        get { return stateMap[key]! }
//        set(v) { stateMap[key] = v }
//    }
//    mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Element == Element {
//        let existing = orderingList[subrange]
//        for k in existing {
//            stateMap[k] = nil
//        }
//        let ks1 = newElements.lazy.map({ $0.key })
//        orderingList.replaceSubrange(subrange, with: ks1)
//        for e in newElements {
//            stateMap[e.key] = e.value
//        }
//    }
//    mutating func insert(_ e: (key: Key, value: Value), at i: Int) {
//        replaceSubrange(i..<i, with: [e])
//    }
//    mutating func remove(at i: Int) {
//        replaceSubrange(i..<i+1, with: [])
//    }
//}
