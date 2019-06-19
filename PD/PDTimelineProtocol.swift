//
//  PDTimelineProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

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
    associatedtype Index
    associatedtype Version: Equatable
    associatedtype Snapshot
    associatedtype Change: PDTimelineChangeProtocol
    associatedtype VersionCollection: RandomAccessCollection where
        VersionCollection.Index == Index,
        VersionCollection.Element == Version
    associatedtype SnapshotCollection: RandomAccessCollection where
        SnapshotCollection.Index == Index,
        SnapshotCollection.Element == Snapshot
    associatedtype ChangeCollection: RandomAccessCollection where
        ChangeCollection.Index == Index,
        ChangeCollection.Element == Change
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
