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
//        var log1 = log.groups.lazy.map({ $0.nodify() })
//        var pdx = PDX2(log1)
//
//        log.groups.append(TXLogGroup())
//        log1 = log.groups.lazy.map({ $0.nodify() })
//        pdx.replay(log1, with: { n in
//            switch n {
//            case .group(let g):
//                let r = g.items.lazy.map({ $0.nodify() })
//                let r1 = PDAnyListRepository<TXLogNode>(r)
//
//                return r1
//            default: fatalError()
//            }
//        })
//    }
//}
//
//private enum TXLogNode {
//    case group(TXLogGroup)
//    case item(TXLogItem)
//}
//private extension TXLogGroup {
//    func nodify() -> TXLogNode {
//        return .group(self)
//    }
//}
//private extension TXLogItem {
//    func nodify() -> TXLogNode {
//        return .item(self)
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
