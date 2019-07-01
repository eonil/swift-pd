//
//  PDTimelineProtocol.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDTimelineProtocol {
    var lazyTimeline: Lazy { return Lazy(base: self) }
    typealias Lazy = PDLazyTimeline<Self>
}
