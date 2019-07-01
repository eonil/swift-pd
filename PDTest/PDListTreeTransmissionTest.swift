//
//  PDListTreeTransmissionTest.swift
//  PDTest
//
//  Created by Henry on 2019/07/01.
//

import XCTest
@testable import PD

class PDListTreeTransmissionTest: XCTestCase {
    func testBasics() {
        var x = PDListTreeTransmission<String>()

        var a = PDListRepository<Int>()
        a.append(111)
        a.append(222)
        a.append(333)
        x.transit(to: a, in: [], with: { "\($0)" })
        let x1 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x1, ["111","222","333"])

        var b = PDListRepository<String>()
        b.append("aaa")
        b.append("bbb")
        x.transit(to: b, in: [0], with: {$0})
        let x2 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x2, ["111","222","333"])
        XCTAssertEqual(x.target.collection.count, 3)
        XCTAssertEqual(x.target.collection[0].collection.count, 2)
        let x3 = Array(x.target.collection[0].collection.map({ $0.value }))
        XCTAssertEqual(x3, ["aaa","bbb"])

        a.append(444)
        a.remove(at: 1)
        x.transit(to: a, in: [], with: { "\($0)" })
        let x4 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x4, ["111","333","444"])

        x.transit(to: b, in: [], with: {$0})
        let x5 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x5, ["aaa","bbb"])
    }
}
