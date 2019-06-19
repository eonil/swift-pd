//
//  PDListRepository.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

public struct PDListRepository<Value>: PDRepositoryProtocol {
    public typealias Timeline = PDTimeline<
        AnyHashable,
        PDList<Value>,
        PDListChange>
    public fileprivate(set) var timeline = Timeline()
    public init() {}
    private init(timeline tl: Timeline) {
        timeline = tl
    }
    public func latest(_ n: Int) -> PDListRepository<Value> {
        guard n < timeline.changes.count else { return self }
        let m = timeline.changes.count - n
        var tl = timeline
        tl.removeFirst(m)
        return PDListRepository(timeline: tl)
    }
}
extension PDListRepository:
MutableCollection,
RangeReplaceableCollection {
    public var startIndex: Int {
        let s = timeline.snapshots.last!
        return s.startIndex
    }
    public var endIndex: Int {
        let s = timeline.snapshots.last!
        return s.endIndex
    }
    public func index(after i: Int) -> Int {
        return i + 1
    }
    public subscript(_ i: Int) -> Value {
        get {
            let s = timeline.snapshots.last!
            return s[i]
        }
        set(v) {
            var s = timeline.snapshots.last!
            s[i] = v
            timeline.versionsImpl.append(AnyHashable(PDIdentity()))
            timeline.snapshotsImpl.append(s)
            timeline.changesImpl.append(PDListChange(from: i..<i, to: i..<i.advanced(by: i)))
        }
    }
    public mutating func replaceSubrange<C>(_ subrange: Range<PDListRepository<Value>.Index>, with newElements: C) where C : Collection, Element == C.Element {
        var s = timeline.snapshots.last!
        s.replaceSubrange(subrange, with: newElements)
        timeline.versionsImpl.append(AnyHashable(PDIdentity()))
        timeline.snapshotsImpl.append(s)
        timeline.changesImpl.append(PDListChange(from: subrange, to: subrange.lowerBound..<subrange.lowerBound.advanced(by: newElements.count)))
    }
}
public struct PDListChange: PDTimelineChangeProtocol {
    public var from: Range<Int>
    public var to: Range<Int>
}
