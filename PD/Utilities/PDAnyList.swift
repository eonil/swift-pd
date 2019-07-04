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
    public init() {
        r = 0..<0
        sfx = { _ in fatalError() }
    }
}
public extension PDAnyList {
    typealias Index = Int
    init<C>(_ c:C) where C:RandomAccessCollection, C.Index == Int, C.Element == Element {
        r = 0..<c.count
        let i = c.startIndex
        sfx = { c[i+$0] }
    }
    var startIndex: Int { return r.startIndex }
    var endIndex: Int { return r.endIndex }
    subscript(_ i: Int) -> Element { return sfx(i) }
}
