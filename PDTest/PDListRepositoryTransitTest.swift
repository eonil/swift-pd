//
//  PDListRepositoryTransitTest.swift
//  PDTest
//
//  Created by Henry on 2019/07/01.
//

import XCTest
@testable import PD

class PDListRepositoryTransitTest: XCTestCase {
    func testBasics() {
        var a = PDListRepository<Int>()
        var b = PDListRepository<String>()
        a.append(111)
        a.append(222)
        a.append(333)
        b.transit(to: a, with: { "\($0)" })
        let b1 = Array(b)
        XCTAssertEqual(b1, ["111","222","333"])
    }
}
