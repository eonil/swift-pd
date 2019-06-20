//
//  PDSumListTest.swift
//  PDTest
//
//  Created by Henry on 2019/06/20.
//

import XCTest
@testable import PD

class PDSumListTest: XCTestCase {
    func test1() {
        typealias L = PDSumList<V>
        typealias R = PD2ListRepository<L>
        var repo = R()
        repo.append(V(100))
        repo.append(V(400))
        repo.append(V(200))
        let s = repo.timeline.points.last!.snapshot
        let (i,x) = s.indexAndOffset(for: 550)
        XCTAssertEqual(i, 2)
        XCTAssertEqual(x, 50)

        for x in repo.timeline.steps {
            x.new
        }
    }
}

private struct V: PDSumProtocol {
    var value: Int

    init(_ v: Int) {
        value = v
    }
    var sum: Int {
        return value
    }
}
