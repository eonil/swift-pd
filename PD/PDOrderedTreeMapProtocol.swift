//
//  PDOrderedTreeMapProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDOrderedTreeMapProtocol: PDSnapshotProtocol
where Selection == PDSet<Key> {
    associatedtype Key: Comparable
    associatedtype Value
    typealias Element = (key: Key, value: Value)


    init(_ root: Element)
    subscript(_ key: Key) -> Value { get set }
    mutating func insert(_ element: Element, at i: Int, in key: Key)
    @discardableResult
    mutating func remove(at i: Int, in key: Key) -> Element
}

extension PDOrderedTreeMap: PDOrderedTreeMapProtocol {}
public extension PDOrderedTreeMap {
    typealias Selection = PDSet<Key>
    mutating func insert(_ element: (key: Key, value: Value), at i: Int, in key: Key) {
        var s = subtree(for: key)!
        s.insert(element, at: i)
        self = s.tree
    }
    mutating func remove(at i: Int, in key: Key) -> Element {
        var s = subtree(for: key)!
        let e = s[i]
        precondition(s.subtree(at: i).count == 0, "You cannot remove a node with children.")
        s.remove(at: i)
        self = s.tree
        return e
    }
}
public extension PDOrderedTreeMap {

}
