//
//  PDOrderedMapTreeStep.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public enum PDOrderedMapTreeStep<Snapshot>:
PDTimelineStepProtocol where
Snapshot: PDMapProtocol {
    /// Only values for the keys has been changed.
    /// No change in topology at all.
    /// Zero-length key-set effectively makes no-op.
    case values(from: ValuesPoint, to: ValuesPoint, at: PDSet<Snapshot.Key>)
    /// Topology of direct subtrees of subtree for the key has been changed.
    /// Target key itself has not been changed.
    /// This also can represents an insertion/removal position
    /// with zero-length
    ///
    /// `from.range` is removed range in `from.snapshot`.
    /// `to.range` is inserted range in`to.range`.
    ///
    case subtrees(from: SubtreesPoint, to: SubtreesPoint, in: Snapshot.Key)
//    /// Same with `subtrees`, but represented in `CollectionDifference` type.
//    @available(OSX 10.15, *)
//    case subtreesDifference(CollectionDifference<Int>, in: Snapshot.Key)

    public typealias ValuesPoint = (time: PDTimestamp, snapshot: Snapshot)
    public typealias SubtreesPoint = (time: PDTimestamp, snapshot: Snapshot, range: Range<Int>)

    public var old: Point {
        switch self {
        case let .values(a,_,_):    return Point(time: a.0, snapshot: a.1)
        case let .subtrees(a,_,_):  return Point(time: a.0, snapshot: a.1)
        }
    }
    public var new: Point {
        switch self {
        case let .values(_,b,_):    return Point(time: b.0, snapshot: b.1)
        case let .subtrees(_,b,_):  return Point(time: b.0, snapshot: b.1)
        }
    }
    public func reversed() -> PDOrderedMapTreeStep<Snapshot> {
        switch self {
        case let .values(a, b, ks):     return .values(from: b, to: a, at: ks)
        case let .subtrees(a, b, k):    return .subtrees(from: b, to: a, in: k)
        }
    }
    
    public struct Point: PDTimelineStepPointProtocol {
        public var time: PDTimestamp
        public var snapshot: Snapshot
    }
}
