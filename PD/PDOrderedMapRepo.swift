////
////  PDOrderedMapRepo.swift
////  PD
////
////  Created by Henry on 2019/06/25.
////
//
//public struct PDOrderedMapRepo<Snapshot>:
//PDRepositoryProtocol,
//PDOrderedMapProtocol where
//Snapshot: PDOrderedMapProtocol {
//    private(set) var impl = Timeline()
//    var latestSnapshot: Snapshot {
//        return impl.steps.last?.new.snapshot ?? Snapshot()
//    }
//    public init() {}
//}
//public extension PDOrderedMapRepo {
//    typealias Timeline = PDTimeline<Snapshot>
//    typealias Element = Snapshot.Element
//    typealias Key = Snapshot.Key
//    typealias Value = Snapshot.Value
//
//    var timeline: Timeline {
//        return impl
//    }
//    mutating func replay(_ x: Timeline) {
//        impl.replay(x)
//    }
//    subscript(_ k: Snapshot.Key) -> Snapshot.Value {
//        get {
//            return latestSnapshot[k]
//        }
//        set(v) {
//            var s = latestSnapshot
//            s[k] = v
//            impl.recordStepping(from: [k], to: [k], with: [v], default: Snapshot())
//        }
//    }
////    mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Element == Element {
////        var s = latestSnapshot
////        s.remove
////        s.replaceSubrange(subrange, with: newElements)
////        impl.recordStepping(
////            from: subrange,
////            to: subrange.lowerBound..<subrange.lowerBound+newElements.count,
////            with: s,
////            default: Snapshot())
////    }
//    mutating func insert(_ e: (key: Snapshot.Key, value: Snapshot.Value), at i: Int) {
//        var s = latestSnapshot
//        s.insert(e, at: i)
//        impl.recordStepping(from: [e.key], to: [e.key], with: s, default: Snapshot())
//    }
//    mutating func remove(at i: Int) -> Element {
//        var s = latestSnapshot
//        s.remove(at: i)
//        impl.recordStepping(from: [e.key], to: [e.key], with: s, default: Snapshot())
//    }
//}
