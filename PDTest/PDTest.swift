//
//  PDTest.swift
//  PDTest
//
//  Created by Henry on 2019/06/20.
//

import XCTest
@testable import PD

class PDTest: XCTestCase {
    func testBasics() {
        typealias R = PDListRepository<Int>
        var repo = R()
        XCTAssertEqual(repo.count, 0)
        XCTAssertEqual(repo.timeline.steps.count, 0)

        repo.append(111)
        repo.append(222)
        repo.append(333)
        XCTAssertEqual(repo.count, 3)
        XCTAssertEqual(repo.timeline.steps.count, 3)
        XCTAssertEqual(Array(repo), [111,222,333])
        XCTAssertEqual(Array(repo.timeline.steps.last!.new.snapshot), [111,222,333])
    }
    func testUndoRedo() {
        typealias R = PDListRepository<Int>
        typealias U = PDUndoRedo<R>
        let initialRepo = R()
        var repo = initialRepo
        var repo1 = initialRepo
        var arc = U()
        XCTAssertEqual(repo.count, 0)
        XCTAssertEqual(repo.timeline.steps.count, 0)
        XCTAssertEqual(arc.past.count, 0)
        XCTAssertEqual(arc.future.count, 0)

        repo.append(111)
        repo.append(222)
        repo.append(333)
        arc.replay(repo.timeline)
        repo = repo.latestOnly
        repo1 = initialRepo
        repo1.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(arc.past.count, 1)
        XCTAssertEqual(arc.future.count, 0)
        XCTAssertEqual(Array(repo), Array(repo1))

        arc.undo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(arc.past.count, 0)
        XCTAssertEqual(arc.future.count, 1)
        XCTAssertEqual(Array(repo), [])

        arc.redo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [111,222,333])
        XCTAssertEqual(arc.past.count, 1)
        XCTAssertEqual(arc.future.count, 0)

        repo.insert(444, at: 1)
        repo.insert(555, at: 3)
        repo.insert(666, at: 5)
        arc.replay(repo.timeline)
        repo = repo.latestOnly
        XCTAssertEqual(Array(repo), [111,444,222,555,333,666])
        XCTAssertEqual(arc.past.count, 2)
        XCTAssertEqual(arc.future.count, 0)

        arc.undo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [111,222,333])
        XCTAssertEqual(arc.past.count, 1)
        XCTAssertEqual(arc.future.count, 1)

        arc.undo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [])
        XCTAssertEqual(arc.past.count, 0)
        XCTAssertEqual(arc.future.count, 2)

        arc.redo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [111,222,333])
        XCTAssertEqual(arc.past.count, 1)
        XCTAssertEqual(arc.future.count, 1)

        arc.redo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [111,444,222,555,333,666])
        XCTAssertEqual(arc.past.count, 2)
        XCTAssertEqual(arc.future.count, 0)

        arc.undo()
        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [111,222,333])
        XCTAssertEqual(arc.past.count, 1)
        XCTAssertEqual(arc.future.count, 1)

        // If test fails after `removeAll`,
        // it might because of wrong default `removeAll`
        // implementation provided by `RangeReplacementCollection`.
        // You can fix it by providing overriden implementations
        // for all `removeAll` overloads.
        repo.removeAll()
        repo.append(contentsOf: [888,999])
        arc.replay(repo.timeline)
        repo = repo.latestOnly
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [888,999])
        XCTAssertEqual(arc.past.count, 2)
        XCTAssertEqual(arc.future.count, 0)

        repo.replay(arc.timeline)
        arc = arc.latestOnly
        XCTAssertEqual(Array(repo), [888,999])
        XCTAssertEqual(arc.past.count, 2)
        XCTAssertEqual(arc.future.count, 0)
    }
}
