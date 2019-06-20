//
//  PD2Repository.swift
//  PD
//
//  Created by Henry on 2019/06/20.
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
/// All versions, snapshots and changed ranges are stored here.
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
/// There's `PD2UndoRedo` type for your convenience.
///
public protocol PD2RepositoryProtocol: PD2ReplayingProtocol {
    var timeline: Timeline { get }

    /// Replays records in timeline automatically from matching version.
    ///
    /// This method find matching version in supplied timeline and re-apply
    /// changes since the version. If there's no matching version, this method
    /// is no-op.
    /// 
    mutating func replay(_: Timeline)
}
