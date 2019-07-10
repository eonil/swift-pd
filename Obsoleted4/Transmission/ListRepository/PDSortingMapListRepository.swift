//
//  PDSortingMapListRepository.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

/// A list that stores key-value pairs in sorted order by comparable key.
///
/// You modify this repository like `Map` and read like `List`.
public struct PDSortingMapListRepository<Key,Value>: PDListRepositoryProtocol where
Key: Comparable {
    private var impl = Timeline()
    public init() {}
    init(timeline tx: Timeline) {
        impl = tx
    }
//    mutating func recordSetStep(_ v: Value?, for k: Key, with t: PDTimestamp) {
//        func determinateOp(old:V?, new:V?) -> Step.Operation? {
//            switch (old,new) {
//            case (nil,nil): return nil
//            case (nil,_):   return
//            }
//        }
//        let p1 = timeline.steps.last?.new ?? Step.Point(time: PDTimestamp(), snapshot: Snapshot())
//        let s1 = p1.snapshot
//        let i1 = s1.index(for: k)!
//        var s2 = s1
//        if let v = v {
//
//        }
//        else {
//
//        }
//        let op = v == nil
//        s2[k] = nil
//        let p2 = Step.Point(time: t, snapshot: s2)
//        let x = Step(operation: .remove, range: i1..<i1+1, old: p1, new: p2)
//        impl.record(x)
//    }
    mutating func recordWholeSnapshotReplacementSteps(_ s: Snapshot, with t: PDTimestamp) {
        if let x1 = timeline.steps.last {
            let p1 = x1.new
            let s1 = p1.snapshot
            let r1 = s1.startIndex..<s1.endIndex
            let p2 = Step.Point(time: PDTimestamp(), snapshot: Snapshot())
            impl.record(Step(operation: .remove, range: r1, old: p1, new: p2))
        }
        // Now existence of last step is guaranteed.
        let x1 = timeline.steps.last!
        let p1 = x1.new
        let s2 = s
        let r2 = s2.startIndex..<s2.endIndex
        let p2 = Step.Point(time: t, snapshot: s2)
        let x2 = Step(operation: .insert, range: r2, old: p1, new: p2)
        impl.record(x2)
    }
    mutating func recordRemoveStep(for k: Key, with t: PDTimestamp) {
        precondition(self[k] != nil)
        let p1 = timeline.steps.last?.new ?? Step.Point(time: PDTimestamp(), snapshot: Snapshot())
        let s1 = p1.snapshot
        let i1 = s1.index(for: k)!
        var s2 = s1
        s2[k] = nil
        let p2 = Step.Point(time: t, snapshot: s2)
        let x = Step(operation: .remove, range: i1..<i1+1, old: p1, new: p2)
        impl.record(x)
    }
    mutating func recordInsertionStep(_ v: Value, for k: Key, with t: PDTimestamp) {
        precondition(self[k] == nil)
        let p1 = timeline.steps.last?.new ?? Step.Point(time: PDTimestamp(), snapshot: Snapshot())
        let s1 = p1.snapshot
        var s2 = s1
        s2[k] = v
        let i2 = s2.index(for: k)!
        let p2 = Step.Point(time: t, snapshot: s2)
        let x = Step(operation: .insert, range: i2..<i2+1, old: p1, new: p2)
        impl.record(x)
    }
    mutating func recordReplacementStep(_ v: Value, for k: Key, with t: PDTimestamp) {
        precondition(self[k] != nil)
        let p1 = timeline.steps.last?.new ?? Step.Point(time: PDTimestamp(), snapshot: Snapshot())
        let s1 = p1.snapshot
        var s2 = s1
        s2[k] = v
        let i = s2.index(for: k)!
        let p2 = Step.Point(time: t, snapshot: s2)
        // As key is same, we can use same index again.
        let x = Step(operation: .replace, range: i..<i+1, old: p1, new: p2)
        impl.record(x)
    }
    var latestSnapshot: Snapshot {
        return impl.steps.last?.new.snapshot ?? Snapshot()
    }
}
public extension PDSortingMapListRepository {
    var startIndex: Int { return 0 }
    var endIndex: Int { return latestSnapshot.count }
    subscript(_ i: Int) -> Element { return latestSnapshot[i] }
}
public extension PDSortingMapListRepository {
    typealias Timeline = PDTimeline<Step>
    typealias Step = PDListStep<Snapshot>
    typealias Snapshot = PDSortingMapList<Key,Value>
    typealias Element = Snapshot.Element
    var timeline: Timeline { return impl }
    var latestOnly: PDSortingMapListRepository {
        guard let x = timeline.steps.last else { return self }
        var z = self
        z.impl = Timeline(x)
        return z
    }
}
public extension PDSortingMapListRepository {
    func latest(since p: PDTimestamp) -> PDSortingMapListRepository? {
        guard let tx = timeline.suffix(since: p) else { return nil }
        return PDSortingMapListRepository(timeline: tx)
    }
    subscript(_ k: Key) -> Value? {
        get {
            return latestSnapshot[k]
        }
        set(v) {
            if let v = v {
                if latestSnapshot[k] != nil {
                    // Replace.
                    recordReplacementStep(v, for: k, with: PDTimestamp())
                }
                else {
                    // Insert.
                    recordInsertionStep(v, for: k, with: PDTimestamp())
                }
            }
            else {
                if latestSnapshot[k] != nil {
                    // Remove.
                    recordRemoveStep(for: k, with: PDTimestamp())
                }
                else {
                    // Ignore.
                }
            }
        }
    }
//    subscript(_ k: Key) -> Value? {
//        return latestSnapshot[k]
//    }
//    mutating func setValues<C>(_ es:C) where
//    C:Collection,
//    C.Element == Element {
//        recordReplacementStep(es, with: PDTimestamp())
//    }
//    mutating func insert<C>(contentsOf es:C) where
//    C:Collection,
//    C.Element == Element {
//        recordInsertingStep(es, with: PDTimestamp())
//    }
//    mutating func insert(_ e: Element) {
//        insert(contentsOf: CollectionOfOne(e))
//    }
//    mutating func removeSubrange<C>(_ ks: C) where
//    C:Collection,
//    C.Element == Key {
//        recordRemovingStep(PDSet(ks), with: PDTimestamp())
//    }
//    mutating func remove(_ k: Key) {
//        removeSubrange(CollectionOfOne(k))
//    }
}
