//
//  PDListTreeRepositoryTransitTest.swift
//  PDTest
//
//  Created by Henry on 2019/07/01.
//

import XCTest
@testable import PD

class PDListTreeRepositoryTransitTest: XCTestCase {
    func testBasics() {
        var a = PDListRepository<Int>()
        var b = PDListTreeRepository<String>()
        a.append(111)
        a.append(222)
        a.append(333)
        b.transit(to: a, in: [], with: { "\($0)" })
        let b1 = Array(b.collection.map({ $0.value }))
        XCTAssertEqual(b1, ["111","222","333"])
    }
}

