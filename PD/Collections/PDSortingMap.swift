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
