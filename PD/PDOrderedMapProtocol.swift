////
////  PDOrderedMapProtocol.swift
////  PD
////
////  Created by Henry on 2019/06/25.
////
//
//import Foundation
//
//public protocol PDOrderedMapProtocol: PDSnapshotProtocol
//where Selection == PDSet<Key> {
//    associatedtype Key: Comparable
//    associatedtype Value
//    typealias Element = (key: Key, value: Value)
//
//    init()
//    func index(for k: Key) -> Int?
//    subscript(_ k: Key) -> Value { get set }
////    mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Element == Element
//    mutating func insert(_ e: Element, at i: Int)
//    @discardableResult
//    mutating func remove(at i: Int) -> Element
//}
//
//extension PDOrderedMap: PDOrderedMapProtocol {}
//public extension PDOrderedMap {
//    typealias Selection = PDSet<Key>
//}
