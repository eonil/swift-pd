//
//  PDRepositoryProtocol.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

import Foundation

/// A multi-versioned collection type.
///
/// Collection
/// ----------
/// This provides "current" collection state.
/// The "current" state is usually latest state,
/// but not necessarily. If your repository support
/// undo/redo feature, "current" state can be different
/// accordingly.
///
/// Timeline
/// --------
/// Timeline describes collection changes over time.
/// All versions, snapshots and changed ranges are stored here.
///
/// Mutators
/// --------
/// You are supposed to place mutators at this level.
/// DO NOT place mutators at timleine.
///
public protocol PDRepositoryProtocol {
    associatedtype Timeline: PDTimelineProtocol
    var timeline: Timeline { get }
}

/// Collection of versions, snapshots and changed ranges.
///
/// Timeline organizes each component like this.
///
///     version0        version1        version2        .
///     snapshot0       snapshot1       snapshot2       .
///     .    \        / .    \        / .               .
///     .     \      /  .     \      /  .               .
///     .      change0  .      change1  .               .
///     .               .               .               .
///     index0          index1          index2          .
///     (`changes.startIndex`)          (`changes.endIndex`)
///     .               .               .               .
///     .               .               .               .
///     .               .               .               index3
///     .               .               .               (`versions.endIndex` and `snapshots.endIndex`)
///
/// Therefore, `versions` and `snapshots` collections are always have one
/// more element than `changes` collection.
///
public protocol PDTimelineProtocol {
    associatedtype Version: Equatable
    associatedtype Snapshot
    associatedtype Change: PDTimelineChangeProtocol
    associatedtype VersionCollection: RandomAccessCollection where VersionCollection.Element == Version
    associatedtype SnapshotCollection: RandomAccessCollection where SnapshotCollection.Element == Snapshot
    associatedtype ChangeCollection: RandomAccessCollection where ChangeCollection.Element == Change
    var versions: VersionCollection { get }
    var snapshots: SnapshotCollection { get }
    var changes: ChangeCollection { get }

    /// Creates a new repository only with latest `n` changes.
    /// - Parameter n:
    ///     If `n > timeline.changes.count`, `self` will be returned.
    ///     Default value must be `1`.
    func latest(_ n: Int) -> Self
}
public extension PDTimelineProtocol where VersionCollection.Index == Int {
    /// Creates a new repository only with latest changes since version. (inslucive)
    /// Returns `nil` if change-set cannot be found. This can happen if designated
    /// version is latest version.
    /// This can return an empty repository with no change-set.
    func latest(since version: Version) -> Self? {
        guard let i = versions.lastIndex(where: { v in v == version }) else { return nil }
        let c = versions.endIndex - i
        return latest(c)
    }
}

/// Designates changed portions.
///
/// Items in `from` portion in older snapshot are removed
/// and items in `to` portion in newer snapshot are inserted.
///
public protocol PDTimelineChangeProtocol {
    associatedtype Portion
    var from: Portion { get }
    var to: Portion { get }
}
