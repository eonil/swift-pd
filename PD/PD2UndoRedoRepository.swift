//
//  PD2UndoRedoRepository.swift
//  PD
//
//  Created by Henry on 2019/06/21.
//

import Foundation

/// A repository with automaic undo/redo support.
public struct PD2UndoRedoRepository<Repository>:
PD2RepositoryProtocol where
Repository: PD2RepositoryProtocol {
    var archive = PD2UndoRedo<Repository.Timeline.Snapshot>()
    var repository: Repository
}
public extension PD2UndoRedoRepository where
Repository: PD2RepositoryProtocol {
    typealias Snapshot = Repository.Timeline.Snapshot
    init(_ r: Repository) {
        repository = r
    }
    var timeline: Repository.Timeline {
        return repository.timeline
    }
    mutating func undo() {
        archive.undo()
        repository.replay(archive.timeline)
        repository.replay(archive.timeline)
    }
    mutating func redo() {
        archive.redo()
        repository.replay(archive.timeline)
    }
    mutating func replay(_ x: Timeline) {
        repository.replay(x)
        archive.replay(repository.timeline)
    }
}
