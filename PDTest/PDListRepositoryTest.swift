//
//  PDListRepositoryTest.swift
//  PDTest
//
//  Created by Henry on 2019/07/01.
//

import XCTest
@testable import PD

class PDListRepositoryTest: XCTestCase {
    func testBasics() {
        var a = PDListRepository<Int>()
        a.append(111)
        a.append(222)
        a.append(333)
//        let a1 = Array(a)
//        XCTAssertEqual(a1, ["111","222","333"])
        XCTAssertEqual(a.count, 3)
        XCTAssertEqual(a[0], 111)
        XCTAssertEqual(a[1], 222)
        XCTAssertEqual(a[2], 333)
        XCTAssertEqual(a.timeline.steps.count, 3)
        XCTAssertEqual(a.timeline.steps[0].operation, .insert)
        XCTAssertEqual(a.timeline.steps[0].range, 0..<1)
        XCTAssertEqual(a.timeline.steps[0].old.snapshot.count, 0)
        XCTAssertEqual(a.timeline.steps[0].new.snapshot.count, 1)
        XCTAssertEqual(a.timeline.steps[1].operation, .insert)
        XCTAssertEqual(a.timeline.steps[1].range, 1..<2)
        XCTAssertEqual(a.timeline.steps[1].old.snapshot.count, 1)
        XCTAssertEqual(a.timeline.steps[1].new.snapshot.count, 2)
        XCTAssertEqual(a.timeline.steps[2].operation, .insert)
        XCTAssertEqual(a.timeline.steps[2].range, 2..<3)
        XCTAssertEqual(a.timeline.steps[2].old.snapshot.count, 2)
        XCTAssertEqual(a.timeline.steps[2].new.snapshot.count, 3)
    }
}
