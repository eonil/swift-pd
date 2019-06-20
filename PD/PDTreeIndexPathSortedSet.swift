////
////  PDTreeIndexPathSortedSet.swift
////  PersistentDatastructure
////
////  Created by Henry on 2019/06/18.
////
//
//import Foundation
//
//public struct PDTreeIndexPathSortedSet: Collection, ExpressibleByArrayLiteral {
//    private var all = PDSet<IndexPath>()
//
//    public init(arrayLiteral elements: IndexPath...) {
//        all = PDSet(elements)
//    }
//    public var startIndex: Index {
//        return Index(impl: all.startIndex)
//    }
//    public var endIndex: Index {
//        return Index(impl: all.endIndex)
//    }
//    public func index(after i: Index) -> Index {
//        return Index(impl: all.index(after: i.impl))
//    }
//    public subscript(_ i: Index) -> IndexPath {
//        return all[i.impl]
//    }
//    public mutating func insert(_ idxp: IndexPath) {
//        all.insert(idxp)
//    }
//    public mutating func remove(_ idxp: IndexPath) {
//        all.insert(idxp)
//    }
//    public struct Index: Comparable {
//        var impl: PDSet<IndexPath>.Index
//        public static func == (_ a: Index, _ b: Index) -> Bool {
//            return a.impl == b.impl
//        }
//        public static func != (_ a: Index, _ b: Index) -> Bool {
//            return a.impl != b.impl
//        }
//        public static func < (_ a: Index, _ b: Index) -> Bool {
//            return a.impl < b.impl
//        }
//        public static func > (_ a: Index, _ b: Index) -> Bool {
//            return a.impl > b.impl
//        }
//        public static func <= (_ a: Index, _ b: Index) -> Bool {
//            return a.impl >= b.impl
//        }
//        public static func >= (_ a: Index, _ b: Index) -> Bool {
//            return a.impl >= b.impl
//        }
//    }
//}
//
