//
//  PDSortingMap.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

import BTree

/// Simple wrap around `BTree.Map` with `RandomAccessCollection` support.
public struct PDSortingMapList<Key,Value>:
RandomAccessCollection,
PDSortingMapProtocol,
PDReplaceableSortingMapProtocol
where Key: Comparable {
    private var impl = Map<Key,Value>()
    public init() {}
    /// Makes an instance of `PDSortingMapList` with collection of key-value pairs.
    /// All keys in collection **must be unique**. You have to make sure tham to be unique
    /// before passing them into here.
    public init<C>(_ c:C) where C:Collection, C.Element == Element {
        for (k,v) in c {
            precondition(self[k] == nil, "A duplicated key has been found.")
            self[k] = v
        }
    }
}
public extension PDSortingMapList {
    typealias Element = (key: Key, value: Value)
    var startIndex: Int {
        return 0
    }
    var endIndex: Int {
        return impl.count
    }
    subscript(_ i: Int) -> Element {
        let idx = impl.index(ofOffset: i)
        let (k,v) = impl[idx]
        return (k,v)
    }
    subscript(_ k: Key) -> Value? {
        get {
            return impl[k]
        }
        set(v) {
            impl[k] = v
        }
    }
    func index(for k: Key) -> Int? {
        guard let idx = impl.index(forKey: k) else { return nil }
        return impl.offset(of: idx)
    }
}

public protocol PDSortingMapProtocol:
RandomAccessCollection {
    associatedtype Key: Comparable
    associatedtype Value
}

public protocol PDReplaceableSortingMapProtocol: PDSortingMapProtocol {
    init()
    subscript(_ k: Key) -> Value? { get set }
}
