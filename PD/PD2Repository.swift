//
//  PD2Repository.swift
//  PD
//
//  Created by Henry on 2019/06/21.
//

/// A change-tracking `Collection` repository.
///
/// Repository tracks and keeps changes in `timeline`
/// and you can utilize this information to replay changes later
/// and elsewhere.
///
/// Repository provides default mutators based on `Snapshot` types.
/// There're two category of supported snapshots.
///
/// - List (`Collection & MutableCollection & RangeReplaceableCollection`).
/// - Tree (`TreeCollection & MutableTreeCollection & NodeReplaceableTreeCollection`).
///
/// If you want to change tracking repository for `Array`, just use array for snapshot type.
///
///     var repo = PD2Repository<Array<Int>>()
///     repo.append(111)
///     repo.append(222)
///     ...
///
/// This library also ships a persistent tree type --  `PDTree`.
/// You also can make tree typed repository.
///
///     var repo = PD2Repository<PDTree<Int>>()
///     repo.insert(111, at: [])
///     repo.insert(222, at: [0])
///     repo.insert(333, at: [1])
///     ...
///
/// - Note:
///     If you never have made any change,
///     timeline must be empty, and this works like
///     an empty list.
///
public struct PD2Repository<Snapshot> where Snapshot: Collection {
    /// Gets timeline that stores tracked changes.
    public private(set) var timeline = Timeline()
    private var latestStep: Timeline.Step {
        return timeline.steps.last!
    }
    private var latestPoint: Timeline.Point {
        return timeline.points.last!
    }
    private var latestSnapshot: Snapshot {
        return latestPoint.snapshot
    }
}
public extension PD2Repository {
    typealias Timeline = PD2Timeline<Snapshot>
    /// Replays changes from another timeline.
    /// Supplied timeline must be continuous from this timeline
    /// to be replayed.
    mutating func replay(_ x: Timeline) {
        timeline.replay(x)
    }
    /// Gets a repo with only latest step.
    /// If there's no step, `self` will be returned
    /// which is just an empty repo.
    var latestOnly: PD2Repository {
        guard let x = timeline.steps.last else { return self }
        var tl = Timeline()
        tl.record(x)
        return PD2Repository(timeline: tl)
    }
}

extension PD2Repository: Sequence where Snapshot: Sequence {}
public extension PD2Repository where Snapshot: Sequence {
    typealias Element = Snapshot.Element
    typealias Iterator = Snapshot.Iterator
    __consuming func makeIterator() -> Iterator {
        return latestSnapshot.makeIterator()
    }
}

// MARK: Collection
extension PD2Repository: Collection where Snapshot: Collection {}
public extension PD2Repository where Snapshot: Collection {
    typealias Index = Snapshot.Index
    var startIndex: Index {
        return latestSnapshot.startIndex
    }
    var endIndex: Index {
        return latestSnapshot.endIndex
    }
    func index(after i: Index) -> Index {
        return latestSnapshot.index(after: i)
    }
    subscript(_ i: Index) -> Element {
        return latestSnapshot[i]
    }
}

extension PD2Repository: MutableCollection where Snapshot: MutableCollection {}
public extension PD2Repository where Snapshot: MutableCollection {
    subscript(_ i: Index) -> Element {
        get { return latestSnapshot[i] }
        set(v) {
            let x = latestStep
            let s = x.new.snapshot
            var s1 = s
            s1[i] = v
            let p = Timeline.Point(
                time: PD2Timestamp(),
                range: i..<s.index(after: i),
                snapshot: s)
            let p1 = Timeline.Point(
                time: PD2Timestamp(),
                range: i..<s1.index(after: i),
                snapshot: s1)
            let x1 = Timeline.Step(old: p, new: p1)
            timeline.record(x1)
        }
    }
}

// MARK: TreeCollection
import Tree

extension PD2Repository: TreeCollection where Snapshot: TreeCollection {}
public extension PD2Repository where Snapshot: TreeCollection {
    typealias Path = Snapshot.Path
    typealias Paths = Snapshot.Paths
    typealias Subtree = Snapshot.Subtree

    func index(for p: Path) -> Index {
        return latestSnapshot.index(for: p)
    }
    var paths: Paths {
        return latestSnapshot.paths
    }
    var subtree: Subtree? {
        return latestSnapshot.subtree
    }
    subscript(_ p: Path) -> Element {
        return latestSnapshot[p]
    }
}

extension PD2Repository: MutableTreeCollection where Snapshot: MutableTreeCollection {}
public extension PD2Repository where Snapshot: MutableTreeCollection {
    subscript(_ i: Index) -> Element {
        get { latestSnapshot[i] }
        set(v) {
            let x = latestStep
            let s = x.new.snapshot
            var s1 = s
            s1[i] = v
            let p = Timeline.Point(
                time: PD2Timestamp(),
                range: i..<s.index(after: i),
                snapshot: s)
            let p1 = Timeline.Point(
                time: PD2Timestamp(),
                range: i..<s1.index(after: i),
                snapshot: s1)
            let x1 = Timeline.Step(old: p, new: p1)
            timeline.record(x1)
        }
    }
}

extension PD2Repository: NodeReplaceableTreeCollection where Snapshot: NodeReplaceableTreeCollection {}
public extension PD2Repository where Snapshot: NodeReplaceableTreeCollection {
    init() {}
    mutating func replaceSubtree<S>(at i: Index, with s: S) where S : TreeCollection, Element == S.Element {
        let x = latestStep
        let s = x.new.snapshot
        var s1 = s
        s1.replaceSubtree(at: i, with: s)
        let p = Timeline.Point(
            time: PD2Timestamp(),
            range: i..<s.index(after: i),
            snapshot: s)
        let p1 = Timeline.Point(
            time: PD2Timestamp(),
            range: i..<s1.index(after: i),
            snapshot: s1)
        let x1 = Timeline.Step(old: p, new: p1)
        timeline.record(x1)
    }
}
