//
//  PDUnorderedTreeMapRepo.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

import Foundation
import Tree

public struct PDUnorderedTreeMapRepo<Element>:
PD2RepositoryProtocol,
Sequence,
Collection {
    private(set) var impl = Timeline()
    public init() {}
    public mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot()
    }
    mutating func recordStepping(from a: Snapshot.SubIndices, to b: Snapshot.SubIndices, with s: Snapshot) {
        let t = PD2Timestamp()
        if let p = impl.steps.last?.new {
            let x = Timeline.Step(
                old: Timeline.Point(
                    time: p.time,
                    selection: a,
                    snapshot: p.snapshot),
                new: Timeline.Point(
                    time: t,
                    selection: b,
                    snapshot: s))
            impl.record(x)
        }
        else {
            let x = Timeline.Step(
                old: Timeline.Point(
                    time: t,
                    selection: a,
                    snapshot: latestSnapshot),
                new: Timeline.Point(
                    time: t,
                    selection: b,
                    snapshot: s))
            impl.record(x)
        }
    }
}
public extension PD2TreeRepo {
    typealias Timeline = PD2Timeline<Snapshot>
    typealias Snapshot = PDTree<Element>

    var timeline: Timeline {
        return impl
    }
}
public extension PD2TreeRepo {
    typealias Path = Snapshot.Path
    typealias SubPaths = Snapshot.SubPaths
//    var startIndex: Index { latestSnapshot.startIndex }
//    var endIndex: Index { latestSnapshot.endIndex }
    subscript(_ p: Path) -> Snapshot.Element {
        get { latestSnapshot[p]  }
        set(v) {
            let s = latestSnapshot
            var s1 = s
            s1[p] = v
            let a = p
            let b = p
            recordStepping(from: a, to: b, with: s)
        }
    }
    mutating func insert(_ e: Element, at p: Path) {
        let s = latestSnapshot
        var s1 = s
        s1[p] = v
        s1.insert(e, at: p)
        let a = p
        let b = p
        recordStepping(from: a, to: b, with: s)
    }
    mutating func insertSubtree<S>(_ s: S, at: Path) where S : Tree, Element == S.Element, Path == S.Path {

    }
    mutating func replaceSubtree<S>(at p: Path, with s: S) where S : Tree, Element == S.Element, Path == S.Path {

    }
    mutating func removeSubtree(at p: Path) {

    }
}
