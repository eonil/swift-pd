//
//  PDListRepository.swift
//  PD
//
//  Created by Henry on 2019/06/23.
//

public struct PDListRepository<Element>:
PDReplayingProtocol,
PDRepositoryProtocol,
PDListRepositoryProtocol,
PDEditableListRepositoryProtocol,
Sequence,
Collection,
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection,
CustomReflectable {
    private(set) var impl = Timeline()
    public init() {}
    public init(timeline z: Timeline) {
        impl = z
    }
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot()
    }
}
public extension PDListRepository {
    typealias Timeline = PDTimeline<PDListStep<PDList<Element>>>
    typealias Step = Timeline.Step
    typealias Snapshot = PDList<Element>

    var timeline: Timeline {
        return impl
    }
    var latestOnly: PDListRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
    func latest(since p: PDTimestamp) -> PDListRepository? {
        guard let tx = timeline.suffix(since: p) else { return nil }
        return PDListRepository(timeline: tx)
    }
    mutating func record(_ x: Step) {
        impl.record(x)
    }
}
public extension PDListRepository {
    typealias Index = Int
    var startIndex: Index {
        return latestSnapshot.startIndex
    }
    var endIndex: Index {
        return latestSnapshot.endIndex
    }
    subscript(_ i: Index) -> Snapshot.Element {
        get {
            return latestSnapshot[i]
        }
        set(v) {
            let x1 = impl.steps.last
            let t1 = x1?.new.time ?? PDTimestamp()
            let t2 = PDTimestamp()
            let s1 = latestSnapshot
            var s2 = s1
            s2[i] = v
            let x2 = Step(
                operation: .replace,
                range: i..<i+1,
                old: Step.Point(time: t1, snapshot: s1),
                new: Step.Point(time: t2, snapshot: s2))
            impl.record(x2)
        }
    }
    /// This is the only way to make `.replace` operation step.
    mutating func setValues<C>(_ es: C, at i: Int) where C:Collection, C.Element == Element {
        let r = i..<i+es.count
        let x1 = impl.steps.last
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let s1 = latestSnapshot
        var s2 = s1
        s2.replaceSubrange(r, with: es)
        let x2 = Step(
            operation: .replace,
            range: r,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    /// This makes consecutive `.remove` and `.insert` steps.
    mutating func replaceSubrange<C, R>(_ r: R, with es: C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
        let q = r.relative(to: self)
        removeSubrange(q)
        insert(contentsOf: es, at: q.lowerBound)
    }
    mutating func removeSubrange(_ r: Range<Int>) {
        let x1 = impl.steps.last
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let s1 = latestSnapshot
        var s2 = s1
        s2.removeSubrange(r)
        let x2 = Step(
            operation: .remove,
            range: r,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    @discardableResult
    mutating func remove(at i: Int) -> Element {
        let e = self[i]
        removeSubrange(i..<i+1)
        return e
    }
    mutating func insert<C>(contentsOf es: C, at i: Int) where C : Collection, Element == C.Element {
        let x1 = impl.steps.last
        let t1 = x1?.new.time ?? PDTimestamp()
        let t2 = PDTimestamp()
        let s1 = latestSnapshot
        var s2 = s1
        s2.insert(contentsOf: es, at: i)
        let x2 = Step(
            operation: .insert,
            range: i..<i+es.count,
            old: Step.Point(time: t1, snapshot: s1),
            new: Step.Point(time: t2, snapshot: s2))
        impl.record(x2)
    }
    mutating func insert(_ e: Element, at i: Int) {
        insert(contentsOf: CollectionOfOne(e), at: i)
    }
    mutating func append(_ e: Element) {
        insert(e, at: endIndex)
    }
    mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        removeSubrange(startIndex..<endIndex)
    }
}
