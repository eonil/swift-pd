//
//  PDListRepository.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

public struct PDListRepository<Snapshot>:
PDRepositoryProtocol where
Snapshot: RandomAccessCollection & MutableCollection & RangeReplaceableCollection,
Snapshot.Index: Strideable {
    public typealias Timeline = PDTimeline<
        AnyHashable,
        Snapshot,
        PDListChange<Snapshot>>
    public fileprivate(set) var timeline: Timeline
    public init(initial s: Snapshot) {
        timeline = Timeline(
            version: AnyHashable(PDIdentity()),
            snapshot: s)
    }
    private init(timeline tl: Timeline) {
        timeline = tl
    }
    public func latest(_ n: Int) -> PDListRepository<Snapshot> {
        guard n < timeline.changes.count else { return self }
        let m = timeline.changes.count - n
        var tl = timeline
        tl.eraseOld(m)
        return PDListRepository(timeline: tl)
    }
}
extension PDListRepository:
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection {
    public var startIndex: Snapshot.Index {
        let s = timeline.snapshots.last!
        return s.startIndex
    }
    public var endIndex: Snapshot.Index {
        let s = timeline.snapshots.last!
        return s.endIndex
    }
    public subscript(_ i: Snapshot.Index) -> Snapshot.Element {
        get {
            let s = timeline.snapshots.last!
            return s[i]
        }
        set(v) {
            replaceSubrange(i..<i.advanced(by: 1), with: [v])
        }
    }
    public mutating func replaceSubrange<C>(
        _ subrange: Range<Snapshot.Index>,
        with newElements: C)
    where
        C: Collection,
        Snapshot.Element == C.Element
    {
        let v = AnyHashable(PDIdentity())
        var s = timeline.snapshots.last!
        s.replaceSubrange(subrange, with: newElements)
        let x = Timeline.Change(
            from: subrange,
            to: subrange.lowerBound..<subrange.lowerBound.advanced(by: newElements.count))
        timeline.recordNew(change: x, version: v, snapshot: s)
    }
}
public struct PDListChange<Snapshot>: PDTimelineChangeProtocol where
Snapshot: RandomAccessCollection {
    public var from: Range<Snapshot.Index>
    public var to: Range<Snapshot.Index>
}


//public struct PDListRepository<Value>: PDRepositoryProtocol {
//    public typealias Timeline = PDTimeline<
//        AnyHashable,
//        PDList<Value>,
//        PDListChange>
//    public fileprivate(set) var timeline = Timeline(
//        version: AnyHashable(PDIdentity()),
//        snapshot: PDList<Value>())
//    public init() {}
//    private init(timeline tl: Timeline) {
//        timeline = tl
//    }
//    public func latest(_ n: Int) -> PDListRepository<Value> {
//        guard n < timeline.changes.count else { return self }
//        let m = timeline.changes.count - n
//        var tl = timeline
//        tl.eraseOld(m)
//        return PDListRepository(timeline: tl)
//    }
//}
//extension PDListRepository:
//MutableCollection,
//RangeReplaceableCollection {
//    public var startIndex: Int {
//        let s = timeline.snapshots.last!
//        return s.startIndex
//    }
//    public var endIndex: Int {
//        let s = timeline.snapshots.last!
//        return s.endIndex
//    }
//    public func index(after i: Int) -> Int {
//        return i + 1
//    }
//    public subscript(_ i: Int) -> Value {
//        get {
//            let s = timeline.snapshots.last!
//            return s[i]
//        }
//        set(v) {
//            let k = AnyHashable(PDIdentity())
//            var s = timeline.snapshots.last!
//            s[i] = v
//            let x = PDListChange(from: i..<i, to: i..<i.advanced(by: i))
//            timeline.recordNew(change: x, version: k, snapshot: s)
//        }
//    }
//    public mutating func replaceSubrange<C>(_ subrange: Range<PDListRepository<Value>.Index>, with newElements: C) where C : Collection, Element == C.Element {
//        let v = AnyHashable(PDIdentity())
//        var s = timeline.snapshots.last!
//        s.replaceSubrange(subrange, with: newElements)
//        let x = PDListChange(from: subrange, to: subrange.lowerBound..<subrange.lowerBound.advanced(by: newElements.count))
//        timeline.recordNew(change: x, version: v, snapshot: s)
//    }
//}
//public struct PDListChange: PDTimelineChangeProtocol {
//    public var from: Range<Int>
//    public var to: Range<Int>
//}
