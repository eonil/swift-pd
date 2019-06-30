//
//  PDListStep.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public struct PDListStep<Snapshot>:
PDTimelineStepProtocol where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int { 
    public var operation = Operation.replace
    /// Range of operation.
    /// For replacements, this range is indices in both point snapshots.
    /// For insertions, this range is indices in new point snapshot.
    /// For removings, this range is indices in old point snapshot.
    public var range = 0..<0
    public var old: Point
    public var new: Point
    public func reversed() -> PDListStep {
        return PDListStep(
            operation: operation.reversed(),
            range: range,
            old: new,
            new: old)
    }
    public typealias Point = PDListStepPoint<Snapshot>
    public typealias Operation = PDListStepOperation
}
public enum PDListStepOperation {
    case insert
    case replace
    case remove
    func reversed() -> PDListStepOperation {
        switch self {
        case .replace:  return .replace
        case .remove:   return .insert
        case .insert:   return .remove
        }
    }
}
