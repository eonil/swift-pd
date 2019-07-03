//
//  PXCollection.swift
//  PDTX
//
//  Created by Henry on 2019/07/04.
//

import Foundation

/// A collection that keeps change history.
protocol PXCollection: Collection {
    var timeline: Timeline { get }
    associatedtype Timeline: PXTimeline
}

protocol PXTimeline {

}
