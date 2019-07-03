//
//  PDListTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/28.
//

import Foundation
import Tree

public struct PDListTreeRepository<Value>:
PDRepositoryProtocol,
ListTreeStorageProtocol,
CustomReflectable {
    private(set) var impl = PDTimeline<Step>()
    private init(impl x: Timeline) {
        impl = x
    }
    public init() {}
}
extension PDListTreeRepository {
    mutating func recordValuesSetting<C>(_ vs: C, at i: Int, in pp: IndexPath, with t: PDTimestamp) where C: Collection, C.Element == Value {
        guard !vs.isEmpty else { return }
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        for (j,v) in vs.enumerated() {
            let p = pp.appending(i+j)
            s2[p].value = v
        }
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = t
        let x2 = Step(
            operation: .setValues,
            path: pp,
            range: i..<i+vs.count,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func recordSubtreesInsertion<C>(contentsOf c: C, at i: Int, in pp: IndexPath, with t: PDTimestamp) where C: Swift.Collection, C.Element == ListTree<Value> {
        guard !c.isEmpty else { return }
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        for (j,t) in c.enumerated() {
            let p = pp.appending(i+j)
            s2.insert(contentsOf: t, at: p)
        }
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = t
        let x2 = Step(
            operation: .insertSubtrees,
            path: pp,
            range: i..<i+c.count,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func recordSubtreesRemoving(_ r: Range<Int>, in pp: IndexPath, with t: PDTimestamp) {
        guard !r.isEmpty else { return }
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        for i in r.lazy.reversed() {
            let p = pp.appending(i)
            s2.remove(at: p)
        }
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = t
        let x2 = Step(
            operation: .removeSubtrees,
            path: pp,
            range: r,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
}
public extension PDListTreeRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Snapshot = ListTreeStorage<Value>
    var timeline: Timeline {
        return impl
    }
    var latestOnly: PDListTreeRepository {
        guard let x = impl.steps.last else { return self }
        return PDListTreeRepository(impl: Timeline(x))
    }
    func latest(since p: PDTimestamp) -> PDListTreeRepository? {
        guard let tx = timeline.suffix(since: p) else { return nil }
        return PDListTreeRepository(impl: tx)
    }
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    mutating func replay(_ x: Step) {
        impl.record(x)
    }
}
public extension PDListTreeRepository {
    var collection: Snapshot.Collection {
        let s = impl.steps.last?.new.snapshot ?? Snapshot()
        return s.collection
    }
    mutating func setValues<C>(_ vs: C, at i: Int, in pp: IndexPath) where C: Collection, C.Element == Value {
        recordValuesSetting(vs, at: i, in: pp, with: PDTimestamp())
    }
    mutating func setValue(_ v: Value, at p: IndexPath) {
        precondition(p.count > 0)
        let c = CollectionOfOne(v)
        let i = p.last!
        let pp = p.dropLast()
        recordValuesSetting(c, at: i, in: pp, with: PDTimestamp())
    }
    mutating func insert<C>(contentsOf c: C, at i: Int, in pp: IndexPath) where C: Collection, C.Element == ListTree<Value> {
        recordSubtreesInsertion(contentsOf: c, at: i, in: pp, with: PDTimestamp())
    }
//    mutating func insert(contentsOf t: ListTree<Value>, at i: Int, in pp: IndexPath) {
//        insert(contentsOf: CollectionOfOne(t), at: i, in: pp)
//    }
//    mutating func insertSubtree(_ t: ListTree<Value>, at p: IndexPath) {
//        precondition(p.count > 0)
//        insert(contentsOf: t, at: p.last!, in: p.dropLast())
//    }
    mutating func insert(_ v: Value, at p: IndexPath) {
        let t = ListTree(value: v)
        let c = CollectionOfOne(t)
        let i = p.last!
        let pp = p.dropLast()
        recordSubtreesInsertion(contentsOf: c, at: i, in: pp, with: PDTimestamp())
    }
    mutating func removeSubrange(_ r: Range<Int>, in pp: IndexPath) {
        recordSubtreesRemoving(r, in: pp, with: PDTimestamp())
    }
//    mutating func remove(at i: Int, in pp: IndexPath) {
//        removeSubrange(i..<i+1, in: pp)
//    }
    mutating func remove(at p: IndexPath) {
        precondition(p.count > 0)
        let i = p.last!
        let r = i..<i+1
        let pp = p.dropLast()
        recordSubtreesRemoving(r, in: pp, with: PDTimestamp())
    }
}
public extension PDListTreeRepository {
    struct Step: PDTimelineStepProtocol {
        public typealias Snapshot = PDListTreeRepository.Snapshot
        /// Operation performed in this step.
        public var operation = Operation.setValues
        /// Path to parent tree of operation.
        public var path = IndexPath()
        /// Range of operation.
        /// For replacements, this range is indices in both point snapshots.
        /// For insertions, this range is indices in new point snapshot.
        /// For removings, this range is indices in old point snapshot.
        public var range = 0..<0
        public var old = Point()
        public var new = Point()

        public func reversed() -> PDListTreeRepository<Value>.Step {
            return Step(
                operation: operation.reversed(),
                path: path,
                range: range,
                old: new,
                new: old)
        }
        public struct Point: PDTimelineStepPointProtocol {
            public var time = PDTimestamp()
            public var snapshot = PDListTreeRepository.Snapshot()
        }
        public enum Operation {
            case setValues
            case insertSubtrees
//            case replaceSubtrees
            case removeSubtrees
            func reversed() -> Operation {
                switch self {
                case .setValues:        return .setValues
                case .removeSubtrees:   return .insertSubtrees
                case .insertSubtrees:   return .removeSubtrees
                }
            }
        }
    }
}
