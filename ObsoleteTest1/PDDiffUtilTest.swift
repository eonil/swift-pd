//
//  PDDiffUtilTest.swift
//  PDTest
//
//  Created by Henry on 2019/06/29.
//

import XCTest
import Tree
import DifferenceKit
@testable import PD

class PDDiffUtilTest: XCTestCase {
    func test1() {
        var r = PDListTreeRepository<Int>()
        r.insert(1, at: [0])
        r.insert(2, at: [1])
        r.insert(3, at: [2])
        r.insert(4, at: [3])
        r.insert(5, at: [4])
        let a = [1,2,3,4,5]
        let b = [1,5]
        r.replayDifferences(from: a, to: b, in: [], with: { $0 })
        XCTAssertEqual(r.collection.count, 2)
        XCTAssertEqual(r.collection[0].value, 1)
        XCTAssertEqual(r.collection[1].value, 5)
    }
}
