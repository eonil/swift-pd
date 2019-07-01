//
//  PDListStep.map.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Foundation

public extension PDListStep {
    typealias Map<X> = PDListStep<X> where
        X: RandomAccessCollection,
        X.Index == Int
    /// Maps snapshot into another type.
    func map<X>(_ mfx: @escaping (PDListStep.Snapshot) -> X) -> Map<X> where
        X: RandomAccessCollection,
        X.Index == Int {
            typealias S = PDListStep<X>
            typealias P = S.Point
            let os = mfx(old.snapshot)
            let ns = mfx(new.snapshot)
            let s = S(
                operation: operation,
                range: range,
                old: P(time: old.time, snapshot: os),
                new: P(time: new.time, snapshot: ns))
            return s
    }
    /// Maps snapshot into any type with element mapping.
    func mapAnyLazyElements<X>(_ mfx: @escaping (Snapshot.Element) -> X) -> Map<PDAnyList<X>> {
        typealias S = PDListStep.Snapshot
        typealias E = S.Element
        return map({ (_ s:S) -> PDAnyList<X> in
            let s1 = s.lazy.map(mfx)
            let s2 = PDAnyList(s1)
            return s2
        })
    }
}
