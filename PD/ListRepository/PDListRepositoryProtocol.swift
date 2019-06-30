//
//  PDListRepositoryProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public protocol PDListRepositoryProtocol:
PDRepositoryProtocol,
RandomAccessCollection,
MutableCollection,
RangeReplaceableCollection where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int,
Index == Snapshot.Index,
Element == Snapshot.Element {
    typealias Step = PDListStep<Snapshot>
//    typealias Element = Snapshot.Element
}
