//
//  PDTreeRepository.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

import Foundation

public typealias PDTree<Value> = PDTreeRepository<Value> where
    Value: TreeProtocol

public struct PDTreeRepository<Value>: PDRepositoryProtocol where
Value: TreeProtocol {
    public typealias Timeline = PDTimeline<
        AnyHashable,
        Value,
        PDTreeTimelineChange>
    public fileprivate(set) var timeline: Timeline
    public init(initial v: Value) {
        timeline = Timeline(version: AnyHashable(PDIdentity()), snapshot: v)
    }
    private init(timeline tl: Timeline) {
        timeline = tl
    }
}
public extension PDTreeRepository where
Value: MutableTreeProtocol,
Value.SubtreeCollection.Index == IndexPath.Element {
    subscript(_ idxp: IndexPath) -> Value {
        get { return timeline.snapshots.last![idxp] }
        set(v) { replace(at: idxp, with: v) }
    }
    mutating func insert(_ element: Value, at idxp: IndexPath) {
        var s = timeline.snapshots.last!
        s.insert(element, at: idxp)
        let v = AnyHashable(PDIdentity())
        let c = PDTreeTimelineChange(from: idxp..<idxp, to: idxp..<idxp.lastAdvanced(1))
        timeline.recordNew(change: c, version: v, snapshot: s)
    }
    mutating func replace(at idxp: IndexPath, with element: Value) {
        var s = timeline.snapshots.last!
        s[idxp] = element
        let v = AnyHashable(PDIdentity())
        let c = PDTreeTimelineChange(from: idxp..<idxp.lastAdvanced(1), to: idxp..<idxp.lastAdvanced(1))
        timeline.recordNew(change: c, version: v, snapshot: s)
    }
    mutating func remove(at idxp: IndexPath) {
        var s = timeline.snapshots.last!
        s.remove(at: idxp)
        let v = AnyHashable(PDIdentity())
        let c = PDTreeTimelineChange(from: idxp..<idxp.lastAdvanced(1), to: idxp..<idxp.lastAdvanced(1))
        timeline.recordNew(change: c, version: v, snapshot: s)
    }
}

public struct PDTreeTimelineChange: PDTimelineChangeProtocol {
    public var from = IndexPath()..<IndexPath()
    public var to = IndexPath()..<IndexPath()
}

extension IndexPath {
    func lastAdvanced(_ n: Int) -> IndexPath {
        let i = last!
        return dropLast().appending(i + n)
    }
}

extension PDTimelineSteppingPoint: Sequence where
Timeline.Snapshot: TreeProtocol,
Timeline.Snapshot.SubtreeCollection.Index == IndexPath.Element,
Timeline.Change.Portion == Range<IndexPath> {
    public typealias Element = Iterator.Element
    public func makeIterator() -> Iterator {
        let it = TreeIndexPathRangeDFSIterator<Timeline.Snapshot>(with: portion, on: snapshot)
        return Iterator(source: snapshot, impl: it)
    }
    public struct Iterator: IteratorProtocol {
        private(set) var source: Timeline.Snapshot
        private(set) var impl: TreeIndexPathRangeDFSIterator<Timeline.Snapshot>
        public mutating func next() -> (IndexPath,Timeline.Snapshot)? {
            guard let idxp = impl.next() else { return nil }
            let v = source[idxp]
            return (idxp,v)
        }
    }
}
