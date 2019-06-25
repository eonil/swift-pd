//
//  PDOrderedTreeMapRepo.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

import Foundation
import Tree

public struct PDOrderedTreeMapRepo<Snapshot>:
PDRepositoryProtocol,
PDOrderedTreeMapProtocol where
Snapshot: PDOrderedTreeMapProtocol {
    private(set) var impl = Timeline()
    private var defaultRootElement: Snapshot.Element
    public init(_ e: Snapshot.Element) {
        defaultRootElement = e
    }
    public mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot(defaultRootElement)
    }
}
public extension PDOrderedTreeMapRepo {
    typealias Timeline = PDTimeline<Snapshot>
    typealias Key = Snapshot.Key
    typealias Value = Snapshot.Value
    typealias Element = Snapshot.Element
    typealias Selection = Snapshot.Selection

    var timeline: Timeline {
        return impl
    }
}
public extension PDOrderedTreeMapRepo {
////    var startIndex: Index { latestSnapshot.startIndex }
////    var endIndex: Index { latestSnapshot.endIndex }
//    subscript(_ p: Path) -> Snapshot.Element {
//        get { latestSnapshot[p]  }
//        set(v) {
//            let s = latestSnapshot
//            var s1 = s
//            s1[p] = v
//            let a = p
//            let b = p
//            recordStepping(from: a, to: b, with: s)
//        }
//    }
//    mutating func insert(_ e: Element, at p: Path) {
//        let s = latestSnapshot
//        var s1 = s
//        s1[p] = v
//        s1.insert(e, at: p)
//        let a = p
//        let b = p
//        recordStepping(from: a, to: b, with: s)
//    }
//    mutating func insertSubtree<S>(_ s: S, at: Path) where S : Tree, Element == S.Element, Path == S.Path {
//
//    }
//    mutating func replaceSubtree<S>(at p: Path, with s: S) where S : Tree, Element == S.Element, Path == S.Path {
//
//    }
//    mutating func removeSubtree(at p: Path) {
//
//    }
}
public extension PDOrderedTreeMapRepo {
    subscript(_ k: Snapshot.Key) -> Snapshot.Value {
        get {
            return latestSnapshot[k]
        }
        set(v) {
            var s = latestSnapshot
            s[k] = v
            let x = Selection.value(k)
            impl.recordStepping(from: x, to: x, with: s, default: Snapshot(defaultRootElement))
        }
    }
    mutating func insert(_ e: Snapshot.Element, at i: Int, in k: Key) {
        var s = latestSnapshot
        s.insert(e, at: i, in: k)
        let a = Selection.subtrees(i..<i, in: k)
        let b = Selection.subtrees(i..<i+1, in: k)
        impl.recordStepping(from: a, to: b, with: s, default: Snapshot(defaultRootElement))
    }
    @discardableResult
    mutating func remove(at i: Int, in k: Key) -> Element {
        var s = latestSnapshot
        let e = s.remove(at: i, in: k)
        let a = Selection.subtrees(i..<i+1, in: k)
        let b = Selection.subtrees(i..<i, in: k)
        impl.recordStepping(from: a, to: b, with: s, default: Snapshot(defaultRootElement))
        return e
    }
}

