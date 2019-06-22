//
//  TreeTest.swift
//  PDTest
//
//  Created by Henry on 2019/06/21.
//

import Foundation
import XCTest
@testable import PD

class TreeTest: XCTestCase {
    func testDFS1() {
        let x = X(value: 11, subtrees: [
            X(value: 22, subtrees: [
                X(value: 33, subtrees: []),
                X(value: 44, subtrees: []),
                ]),
            X(value: 55, subtrees: [
                X(value: 66, subtrees: []),
                ])
            ])

        var i = x.startIndex
        XCTAssertEqual(i, [])
        XCTAssertEqual(x[i].value, 11)

        i = x.index(after: i)
        XCTAssertEqual(i, [0])
        XCTAssertEqual(x[i].value, 22)

        i = x.index(after: i)
        XCTAssertEqual(i, [0,0])
        XCTAssertEqual(x[i].value, 33)

        i = x.index(after: i)
        XCTAssertEqual(i, [0,1])
        XCTAssertEqual(x[i].value, 44)

        i = x.index(after: i)
        XCTAssertEqual(i, [1])
        XCTAssertEqual(x[i].value, 55)

        i = x.index(after: i)
        XCTAssertEqual(i, [1,0])
        XCTAssertEqual(x[i].value, 66)

        i = x.index(after: i)
        XCTAssertEqual(i, [2])
        XCTAssertEqual(i, x.endIndex)
    }
    func test1() {
        let x = X(value: 11, subtrees: [
            X(value: 22, subtrees: [
                X(value: 33, subtrees: []),
                X(value: 44, subtrees: []),
                ]),
            X(value: 55, subtrees: [
                X(value: 66, subtrees: []),
                ])
            ])

        let a = x.map({ $0.value })
        XCTAssertEqual(a, [11,22,33,44,55,66])
    }
}

private struct X: TreeProtocol {
    var value = 0
    var subtrees = [X]()
}
