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
