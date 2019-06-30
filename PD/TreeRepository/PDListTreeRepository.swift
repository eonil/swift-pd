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
ListTreeStorageProtocol {
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
}
public extension PDListTreeRepository {
    var collection: Snapshot.Collection {
        let s = impl.steps.last?.new.snapshot ?? Snapshot()
        return s.collection
    }
    mutating func setValue(_ v: Value, at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2[p].value = v
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let x2 = Step(
            operation: .setValues,
            path: p.dropLast(),
            range: p.last!..<p.last!+1,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func insert(contentsOf t: ListTree<Value>, at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.insert(contentsOf: t, at: p)
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let x2 = Step(
            operation: .insertSubtrees,
            path: p.dropLast(),
            range: p.last!..<p.last!+1,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func insert(_ v: Value, at p: IndexPath) {
        let t = ListTree(value: v)
        insert(contentsOf: t, at: p)
    }
    mutating func remove(at p: IndexPath) {
        let x1 = impl.steps.last
        let s1 = x1?.new.snapshot ?? Snapshot()
        var s2 = s1
        s2.remove(at: p)
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let x2 = Step(
            operation: .removeSubtrees,
            path: p.dropLast(),
            range: p.last!..<p.last!+1,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
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
