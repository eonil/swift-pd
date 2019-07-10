//
//  PDTimeline.extension.swift
//  PDTest
//
//  Created by Henry on 2019/06/20.
//

import Foundation
import PD

extension PDTimeline {
    var times: [Time] {
        return points.map({ p in p.time })
    }
}
