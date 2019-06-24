//
//  PDTimeline.util.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

import Foundation

// - MARK: Util
extension PDTimeline {
    mutating func recordStepping(from a: Snapshot.Selection, to b: Snapshot.Selection, with s: Snapshot, default f: @autoclosure() -> Snapshot) {
        let t = PDTimestamp()
        if let p = steps.last?.new {
            let x = Step(
                old: Point(
                    time: p.time,
                    snapshot: p.snapshot,
                    selection: a),
                new: Point(
                    time: t,
                    snapshot: s,
                    selection: b))
            record(x)
        }
        else {
            let x = Step(
                old: Point(
                    time: t,
                    snapshot: f(),
                    selection: a),
                new: Point(
                    time: t,
                    snapshot: s,
                    selection: b))
            record(x)
        }
    }
}
