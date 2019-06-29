//
//  PDListTreeRepositoryTest.swift
//  PDTest
//
//  Created by Henry on 2019/06/29.
//

import XCTest
import Tree
@testable import PD

class PDListTreeRepositoryTest: XCTestCase {
    func testSetValue() {
        var r = PDListTreeRepository<Int>()
        r.insert(2222, at: [0])
        XCTAssertEqual(r.timeline.steps.last!.new.snapshot[[0]].value, 2222)
        r.setValue(4444, at: [0])
        XCTAssertEqual(r.timeline.steps.last!.new.snapshot[[0]].value, 4444)
    }
}
