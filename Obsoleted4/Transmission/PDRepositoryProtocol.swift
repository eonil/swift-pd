//
//  PDRepositoryProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

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
/// All timestamps, snapshots and changed ranges are stored here.
///
/// Mutators
/// --------
/// You are supposed to place mutators at this level.
/// DO NOT place mutators at timleine.
///
/// Undo/Redo
/// ---------
/// Repository keeps all mutations, but do not support
/// undo/redo by default. You need to implement it yourself.
/// There's `PDUndoRedo` type for your convenience.
///
public protocol PDRepositoryProtocol {
    associatedtype Snapshot

    var timeline: Timeline { get }
    associatedtype Timeline: PDTimelineProtocol where
        Timeline.Snapshot == Snapshot

    typealias Step = Timeline.Step

    var latestOnly: Self { get }

    /// Gets repository from specific time-point.
    ///
    /// This includes steps starting with supplied time-point.
    ///
    /// - Returns:
    ///     `nil` if there's no step since the time-point.
    func latest(since p: PDTimestamp) -> Self? 
}

//public protocol PDReplaceableMutableRepositoryProtocol: PDReplayingProtocol {
//    init()
//}
