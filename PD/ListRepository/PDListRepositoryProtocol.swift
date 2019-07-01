//
//  PDListRepositoryProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public protocol PDListRepositoryProtocol:
PDRepositoryProtocol,
RandomAccessCollection where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int,
Snapshot.Index == Index,
Snapshot.Element == Element {
    typealias Step = PDListStep<Snapshot>
}

public protocol PDEditableListRepositoryProtocol:
PDListRepositoryProtocol,
MutableCollection,
RangeReplaceableCollection {
}
