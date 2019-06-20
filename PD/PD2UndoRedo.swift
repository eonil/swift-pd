//
//  PD2UndoRedo.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

/// Manages undo/redo records.
///
///     var repo = PD2ListRepository<[String]>()
///     var archive = PD2UndoRedo<[String]>()
///     repo.append("AAA")
///     repo.append("BBB")
///     repo.append("CCC")
///
/// Here, you store last 3 appendings as single action into archive.
/// Notice that 3 operations becomes single undo action.
///
///     archive.replay(repo.timeline)
///
/// Undo.
///
///     archive.undo()
///     repo.replay(archive.timeline)
///     assert(repo.count == 0)
///
/// You undid 3 operations in `repo`. Now `repo` has no item.
/// Redo.
///
///     // Redo.
///     archive.redo()
///     repo.replay(archive.timeline)
///     assert(repo.count == 3)
///
/// You redid 3 operations in `repo`. Now `repo` has 3 items again.
///
public protocol PD2UndoRedoProtocol: PD2ReplayingProtocol {
    /// Accumulative timeline.
    /// Changes made by undo/redo will be appended to this timeline.
    /// This is provided for rendering convenience.
    var timeline: Timeline { get }

    var canUndo: Bool { get }
    /// Moves last action from `past` to `future`,
    /// and executes reversd changes to `timeline`.
    mutating func undo()

    var canRedo: Bool { get }
    /// Moves first action from `future` to `past`,
    /// and re-applied  changes to `timeline`.
    mutating func redo()

    /// Append new changes from supplied timeline as a new action.
    /// If there's any undid action, it will be lost and new action will be recorded.
    mutating func replay(_: Timeline)
}

public struct PD2UndoRedo<Snapshot> where
Snapshot: Collection {
    public typealias Timeline = PD2Timeline<Snapshot>

    /// Past changes.
    /// These are inter-connected timelines divided by action units.
    /// Last timeline always contains first "present" snapshot at last.
    private var past = PDList<Timeline>()
    /// Future changes.
    /// These are inter-connected timelines divided by action units.
    /// First timeline always contains last "present" snapshot at first.
    private var future = PDList<Timeline>()

    public private(set) var timeline = Timeline()

    public var canUndo: Bool {
        return !past.isEmpty
    }

    public mutating func undo() {
        precondition(canRedo, "No past.")
        let x = past.removeLast()
        future.insert(x, at: 0)
        timeline.record(contentsOf: x.reversed())
    }

    public var canRedo: Bool {
        return !future.isEmpty
    }
    public mutating func redo() {
        precondition(canRedo, "No future.")
        let x = future.removeFirst()
        past.append(x)
        timeline.record(contentsOf: x)
    }

    public mutating func replay(_ x: Timeline) {
        future.removeAll()
        if let p = timeline.steps.last {
            let v = p.new.version
            let x1 = x.steps(since: v)
            guard !x1.steps.isEmpty else { return }
            past.append(x1)
            timeline.record(contentsOf: x1)
        }
        else {
            // Undo stack is empty.
            past.append(x)
            timeline.record(contentsOf: x)
        }
    }
}
