//
//  PDTimeline.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

public struct PDTimeline<Version,Snapshot,Change>: PDTimelineProtocol where
Version: Equatable,
Change: PDTimelineChangeProtocol {
    private(set) var versionsImpl = PDList<Version>()
    private(set) var snapshotsImpl = PDList<Snapshot>()
    private(set) var changesImpl = PDList<Change>()

    public typealias Index = Int
    public init(version v: Version, snapshot s: Snapshot) {
        versionsImpl.append(v)
        snapshotsImpl.append(s)
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

    public mutating func recordNew(change: Change, version: Version, snapshot: Snapshot) {
        precondition(!versions.isEmpty,"You cannot append new change if there's no snapshot point.")
        versionsImpl.append(version)
        changesImpl.append(change)
        snapshotsImpl.append(snapshot)
    }
    /// Removes first changes, versions and snapshots.
    /// - Parameter n:
    ///     This must be `>= 0`.
    ///     Clipping erases oldest changes, versions and snapshots.
    ///     If you drop `changes.count`, only latest snapshot will remain.
    ///     If you drop `snapshots.count`, everything will be erased.
    public mutating func eraseOld(_ n: Int = 1) {
        precondition(n >= 0, "Capacity must be larger than or equal to 0.")
        versionsImpl.removeFirst(n)
        snapshotsImpl.removeFirst(n)
        changesImpl.removeFirst(n)
    }
    public func latest(_ n: Int = 1) -> PDTimeline {
        guard n < changes.count else { return self }
        let m = changes.count - n
        var q = self
        q.eraseOld(m)
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
