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
        var x = PDListTreeRepository<String>()
        a.append(111)
        a.append(222)
        a.append(333)
        x.transit(to: a, in: [], with: { "\($0)" })
        let x1 = Array(x.collection.map({ $0.value }))
        XCTAssertEqual(x1, ["111","222","333"])

        var b = PDListRepository<String>()
        b.append("aaa")
        b.append("bbb")
        x.transit(to: b, in: [0], with: {$0})
        let x2 = Array(x.collection.map({ $0.value }))
        let x3 = Array(x.collection[0].collection.map({ $0.value }))
        XCTAssertEqual(x2, ["111","222","333"])
        XCTAssertEqual(x3, ["aaa","bbb"])

        a.append(444)
        a.remove(at: 1)
        x.transit(to: a, in: [], with: { "\($0)" })
        let x4 = Array(x.collection.map({ $0.value }))
        XCTAssertEqual(x4, ["111","333","444"])
    }
}

