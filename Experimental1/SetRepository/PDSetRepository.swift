//
//  PDSetRepository.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

import BTree

/// A repository stores ordered set.
///
/// Ordering is a feature of this type and not an implementation artifact.
///
/// This is an optimization of `PDListRepository` using
/// B-Tree native ordering.
///
public struct PDSetRepository<Element>:
PDRepositoryProtocol,
Collection,
CustomReflactable where
Element: Comparable {
    private(set) var impl = Timeline()
}
public extension PDSetRepository {
    typealias Timeline = PDTimeline<Step>
    mutating func insert(_ e: Element) {

    }
    mutating func remove(_ e: Element) {

    }
}

public protocol PDSetRepositoryProtocol {
    typealias Step = PDSetStep<Element>
    typealias Snapshot = Step.Snapshot
    /// Treat this type as an opaque type.
    typealias Index = Snapshot.Index
}


// MARK: Step
public struct PDSetStep<Element>: PDTimelineStepProtocol {
    public var operation: Operation
    public var keys: PDSet<Element>
    public var old: Point
    public var new: Point
}
public extension PDSetStep {
    typealias Operation = PDSetStepOperation
    typealias Point = PDTimelineStepPoint<Snapshot>
    typealias Snapshot = PDSet<Element>
    func reversed() -> PDSetStep {
        return PDSetStep(
            operation: operation.reversed(),
            keys: keys,
            old: new,
            new: old)
        )
    }
}
public enum PDSetStepOperation {
    case insert
    case replace
    case remove
    func reversed() -> PDSetStepOperation {
        switch self {
        case .replace:  return .replace
        case .remove:   return .insert
        case .insert:   return .remove
        }
    }
}
