//
//  PDTimeline.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

public struct PDTimeline<Version,Snapshot,Change>: PDTimelineProtocol where
Version: Equatable,
Change: PDTimelineChangeProtocol {
    var versionsImpl = PDList<Version>()
    var snapshotsImpl = PDList<Snapshot>()
    var changesImpl = PDList<Change>()

    public init() {}
    public init(version: Version, snapshot: Snapshot) {

    }
    public var versions: ComponentCollection<Version> {
        return ComponentCollection(impl: versionsImpl)
    }
    public var snapshots: ComponentCollection<Snapshot> {
        return ComponentCollection(impl: snapshotsImpl)
    }
    public var changes: ComponentCollection<Change> {
        return ComponentCollection(impl: changesImpl)
    }
//    mutating func append(contentsOf other: PDTreeTimeline) {
//        precondition(
//            versions.last! == other.versions.first!,
//            "`other` timeline does not start" +
//                " with last version of this timeline." +
//            " therefore cannot be appended.")
//        versionsImpl.append(contentsOf: other.versions.dropFirst())
//        snapshotsImpl.append(contentsOf: other.snapshots.dropFirst())
//        changesImpl.append(contentsOf: other.changesImpl)
//    }

    mutating func append(change: Change, version: Version, snapshot: Snapshot) {

    }
    /// Removes first changes, versions and snapshots.
    /// - Parameter n:
    ///     This must be `>= 0`.
    ///     Clipping erases oldest changes, versions and snapshots.
    ///     If you drop `changes.count`, only latest snapshot will remain.
    ///     If you drop `snapshots.count`, everything will be erased.
    mutating func removeFirst(_ n: Int = 1) {
        precondition(n >= 0, "Capacity must be larger than or equal to 0.")
        versionsImpl.removeFirst(n)
        snapshotsImpl.removeFirst(n)
        changesImpl.removeFirst(n)
    }
    public func latest(_ n: Int = 1) -> PDTimeline {
        guard n < changes.count else { return self }
        let m = changes.count - n
        var q = self
        q.removeFirst(m)
        return q
    }

    public struct ComponentCollection<T>: RandomAccessCollection {
        var impl: PDList<T>
        public var startIndex: Int {
            return impl.startIndex
        }
        public var endIndex: Int {
            return impl.endIndex
        }
        public subscript(_ i: Int) -> T {
            return impl[i]
        }
    }
}

public struct PDTimelineStepping<Version,Snapshot,Change> where
Change: PDTimelineChangeProtocol {
    public typealias Point = PDTimelineSteppingPoint<Version,Snapshot,Change>
    public var from: Point
    public var to: Point
}

public struct PDTimelineSteppingPoint<Version,Snapshot,Change> where
Change: PDTimelineChangeProtocol {
    public var version: Version
    public var snapshot: Snapshot
    public var portion: Change.Portion
}

public extension PDTimeline {
    typealias Stepping = PDTimelineStepping<Version,Snapshot,Change>
    var steppins: SteppingCollection {
        return SteppingCollection(impl: self)
    }
    struct SteppingCollection: Collection {
        private(set) var impl: PDTimeline
        public var startIndex: Int {
            return 0
        }
        public var endIndex: Int {
            return impl.changes.count
        }
        public func index(after i: Int) -> Int {
            return i + 1
        }
        public subscript(_ i: Int) -> Stepping {
            return Stepping(
                from: Stepping.Point(
                    version: impl.versions[i],
                    snapshot: impl.snapshots[i],
                    portion: impl.changes[i].from),
                to: Stepping.Point(
                    version: impl.versions[i+1],
                    snapshot: impl.snapshots[i+1],
                    portion: impl.changes[i].to))
        }
    }
}
