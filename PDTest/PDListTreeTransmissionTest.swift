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
        x.transit(to: a.lazy.map({ "\($0)" }), in: [])
        let x1 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x1, ["111","222","333"])

        var b = PDListRepository<String>()
        b.append("aaa")
        b.append("bbb")
        x.transit(to: b.lazy.map({$0}), in: [0])
        let x2 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x2, ["111","222","333"])
        XCTAssertEqual(x.target.collection.count, 3)
        XCTAssertEqual(x.target.collection[0].collection.count, 2)
        let x3 = Array(x.target.collection[0].collection.map({ $0.value }))
        XCTAssertEqual(x3, ["aaa","bbb"])

        a.append(444)
        a.remove(at: 1)
        x.transit(to: a.lazy.map({"\($0)"}), in: [])
        let x4 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x4, ["111","333","444"])

        x.transit(to: b.lazy.map({$0}), in: [])
        let x5 = Array(x.target.collection.map({ $0.value }))
        XCTAssertEqual(x5, ["aaa","bbb"])
    }
    func testTwoDepth() {
        typealias G = XSampleGroup
        typealias X = XSampleItem
        typealias N = XSampleViewNode
        var a = PDListRepository<G>()
        var x = PDListTreeTransmission<N>()

        do {
            var g = G()
            g.start = Date(timeIntervalSince1970: 1111)
            a.append(g)
            a[0].items.append(X(message: "aaa"))
            do {
                let a1 = a.lazy.map({ N.group($0) })
                let a2 = PDAnyListRepository(a1)
                x.transit(to: a2, in: [], with: { $0.subrepository })
                XCTAssertEqual(x.target.collection.count, 1)
                let v1 = x.target.collection[0].value
                let t1 = v1.group?.start
                XCTAssertEqual(t1, Date(timeIntervalSince1970: 1111))
                XCTAssertEqual(x.target.collection[0].collection.count, 1)
                let v2 = x.target.collection[0].collection[0].value
                let m2 = v2.item?.message
                XCTAssertEqual(m2, "aaa")
            }
        }
        do {
            a[0].items.append(X(message: "bbb"))
            XCTAssertEqual(a[0].items.timeline.steps.count, 2)
            let a1 = a.lazy.map({ N.group($0) })
            let a2 = PDAnyListRepository(a1)
            x.transit(to: a2, in: [], with: { $0.subrepository })
            XCTAssertEqual(x.target.collection.count, 1)
            let v1 = x.target.collection[0].value
            let t1 = v1.group?.start
            XCTAssertEqual(t1, Date(timeIntervalSince1970: 1111))
            XCTAssertEqual(x.target.collection[0].collection.count, 2)
            let v2 = x.target.collection[0].collection[0].value
            let m2 = v2.item?.message
            XCTAssertEqual(m2, "aaa")
            let v3 = x.target.collection[0].collection[1].value
            let m3 = v3.item?.message
            XCTAssertEqual(m3, "bbb")
        }
    }
}


private struct XSampleGroup {
    var start = Date(timeIntervalSince1970: 0)
    var items = PDListRepository<XSampleItem>()
}
private struct XSampleItem {
    var message = ""
}

private enum XSampleViewNode {
    case group(XSampleGroup)
    case item(XSampleItem)
    var subrepository: PDAnyListRepository<XSampleViewNode>? {
        switch self {
        case .group(let g): return PDAnyListRepository(g.items.lazy.map({ XSampleViewNode.item($0) }))
        case .item(_):      return nil
        }
    }
    var group: XSampleGroup? {
        guard case let .group(g) = self else { return nil }
        return g
    }
    var item: XSampleItem? {
        guard case let .item(x) = self else { return nil }
        return x
    }
}
