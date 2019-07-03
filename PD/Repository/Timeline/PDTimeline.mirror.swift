//
//  PDTimeline.mirror.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public extension PDTimeline {
    var customMirror: Mirror {
        return Mirror(self, children: [
            "steps": Array(steps),
            "points": Array(points)])
    }
}

