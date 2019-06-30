////
////  PDXTest.swift
////  PDTest
////
////  Created by Henry on 2019/06/30.
////
//
//import XCTest
//@testable import PD
//
//class PDXTest: XCTestCase {
//    func test1() {
//        var log = TXLog()
//        let r1 = log.groups.lazyRepository.map({ $0.nodify() })
//        let r2 = log.groups.lazyMap({ $0.nodify() })
////        r2.timeline.steps.last
//
//        var a = PDListRepository<AAA>()
//        a.lazyRepository.map({ (_ x: AAA) -> PDXElement<Int> in
//            PDXElement(
//                value: x.val,
//                subrepository: bbb.lazyRepository.map({ x1 in
//                    x1
//                }))
//        })
////        var a = PDListRepository<Int>()
////        var b = a.lazyRepository.map
////        var x = PDX
//    }
//}
//
//private enum TXNode {
//    case group(TXLogGroup)
//    case item(TXLogItem)
//}
//private extension TXLogGroup {
//    func nodify() -> TXNode {
//        return TXNode.group(self)
//    }
//}
//private extension TXLogItem {
//    func nodify() -> TXNode {
//        return TXNode.item(self)
//    }
//}
//
//
//
//private typealias ListRepo<V> = PDListRepository<V>
//private struct TXLog {
//    var groups = ListRepo<TXLogGroup>()
//}
//private struct TXLogGroup {
//    var items = ListRepo<TXLogItem>()
//}
//private struct TXLogItem {
//    var message = ""
//}
//
//
//
//
//
//
//
