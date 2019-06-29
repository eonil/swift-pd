//
//  PDListTreeRepository.swift
//  PD
//
//  Created by Henry on 2019/06/28.
//

import Foundation
import Tree

public struct PDListTreeRepository<Value>: PDRepositoryProtocol {
    private(set) var impl = PDTimeline<Step>()
    private init(impl x: Timeline) {
        impl = x
    }
    public init() {}
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
    mutating func replay(_ x: Timeline) {
        impl.replay(x)
    }
    mutating func replay(_ x: Step) {
        impl.record(x)
    }
    mutating func setValue(_ v: Value, at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2[p].value = v

        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let r1 = p.last!..<p.last!+1
        let r2 = p.last!..<p.last!+1
        let x2 = Step(
            old: Step.Point(
                time: t1,
                snapshot: s1,
                path: p.dropLast(),
                range: r1),
            new: Step.Point(
                time: t2,
                snapshot: s2,
                path: p.dropLast(),
                range: r2))
        impl.record(x2)
    }
    mutating func insert(contentsOf t: ListTree<Value>, at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.insert(contentsOf: t, at: p)

        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let r1 = p.last!..<p.last!
        let r2 = p.last!..<p.last!+1
        let x2 = Step(
            old: Step.Point(
                time: t1,
                snapshot: s1,
                path: p.dropLast(),
                range: r1),
            new: Step.Point(
                time: t2,
                snapshot: s2,
                path: p.dropLast(),
                range: r2))
        impl.record(x2)
    }
    mutating func insert(_ v: Value, at p: IndexPath) {
        let t = ListTree(value: v)
        insert(contentsOf: t, at: p)
    }
    mutating func remove(_ t: ListTree<Value>, at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.remove(at: p)

        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let r1 = p.last!..<p.last!+1
        let r2 = p.last!..<p.last!
        let x2 = Step(
            old: Step.Point(
                time: t1,
                snapshot: s1,
                path: p.dropLast(),
                range: r1),
            new: Step.Point(
                time: t2,
                snapshot: s2,
                path: p.dropLast(),
                range: r2))
        impl.record(x2)
    }
}
public extension PDListTreeRepository {
    struct Step: PDTimelineStepProtocol {
        public typealias Snapshot = PDListTreeRepository.Snapshot
        public var old = Point()
        public var new = Point()
        public struct Point: PDTimelineStepPointProtocol {
            public var time = PDTimestamp()
            public var snapshot = PDListTreeRepository.Snapshot()
            /// Path to parent tree.
            public var path = IndexPath()
            /// Selected range in parent tree.
            public var range = 0..<0
        }
        public func reversed() -> PDListTreeRepository<Value>.Step {
            return Step(old: new, new: old)
        }
    }
}
