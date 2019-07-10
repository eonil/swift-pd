//
//  PDListTreeStep.swift
//  PD
//
//  Created by Henry on 2019/07/04.
//

import Foundation
import Tree

public struct PDListTreeStep<Value>: PDTimelineStepProtocol {
    public typealias Snapshot = ListTreeStorage<Value>
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

    public func reversed() -> PDListTreeStep {
        return PDListTreeStep(
            operation: operation.reversed(),
            path: path,
            range: range,
            old: new,
            new: old)
    }
    public struct Point: PDTimelineStepPointProtocol {
        public typealias Snapshot = PDListTreeStep.Snapshot
        public var time = PDTimestamp()
        public var snapshot = Snapshot()
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
