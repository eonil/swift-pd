//
//  PDListStep.util.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

extension PDListStep where Snapshot: RangeReplaceableCollection {
    static func wholeReplacementSteps(from a:Point, to b:Point) -> [PDListStep] {
        typealias S = PDListStep
        typealias P = Point
        let t = PDTimestamp()
        let p = P(time: t, snapshot: Snapshot())
        let `as` = a.snapshot
        let bs = b.snapshot
        let x1 = S(
            operation: .remove,
            range: `as`.startIndex..<`as`.endIndex,
            old: a,
            new: p)
        let x2 = S(
            operation: .insert,
            range: bs.startIndex..<bs.endIndex,
            old: p,
            new: b)
        return [x1,x2]
    }
}
