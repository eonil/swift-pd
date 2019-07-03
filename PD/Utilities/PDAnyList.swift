//
//  PDAnyList.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

/// Something like `AnyRandomAccessCollection` but `Index == Int`.
public struct PDAnyList<Element>: RandomAccessCollection {
    private let r: Range<Int>
    private let sfx: (Int) -> Element
    init<C>(_ c:C) where C:RandomAccessCollection, C.Index == Int, C.Element == Element {
        r = c.startIndex..<c.endIndex
        sfx = { c[$0] }
    }
}
public extension PDAnyList {
    typealias Index = Int
    var startIndex: Int { return r.startIndex }
    var endIndex: Int { return r.endIndex }
    subscript(_ i: Int) -> Element { return sfx(i) }
}
