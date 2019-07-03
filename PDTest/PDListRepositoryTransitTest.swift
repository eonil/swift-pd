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
        var b = PDListRepository<Int>()
        a.append(111)
        a.append(222)
        a.append(333)
        a.transfer(to: &b)
        let b1 = Array(b)
        XCTAssertEqual(b1, [111,222,333])
    }
}
