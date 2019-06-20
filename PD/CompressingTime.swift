////
////  CompressingTime.swift
////  PD
////
////  Created by Henry on 2019/06/20.
////
//
//import Foundation
//
//struct CompressingTime {
//
//}
//
//final class GlobalTimePointManagement {
//    static let shared = GlobalTimePointManagement()
//
//    var slots = [()-> GlobalTimePoint?]()
//    private var compressionRequestQueue = Int?.none
//
//    func issue() -> GlobalTimePoint {
//        let p = GlobalTimePoint()
//        weak var p1 = p
//        slots.append({ p1 })
//        return p
//    }
//    func findFirstEmptyIndex() -> Int? {
//        for i in slots.indices {
//            if slots[i]() == nil {
//                return i
//            }
//        }
//        return nil
//    }
//    func compress() {
//        guard var k = findFirstEmptyIndex() else { return }
//        for i in k..<slots.count {
//            if let p = slots[i]() {
//                p.index = k
//                weak var p1 = p
//                slots[k] = {p1}
//                k += 1
//            }
//        }
//    }
//    func queueCompression(at index: Int) {
//        if index < (compressionRequestQueue ?? .max) {
//            compressionRequestQueue = index
//        }
//    }
//}
//final class GlobalTimePoint {
//    var index = 0
//    deinit {
//        GlobalTimePointManagement.shared.compress()
//    }
//}
//
///// A time-point with infinite resolution.
/////
///// This is designed to be used as an ordered globally unique identifier.
///// Order is defined by time of instance creation.
/////
//struct InfiniteResolutionTimePoint {
//    var local = 0 as Int32
//    var offset = 0 as Int32
//}
//
///// IRTP uses local value for ordering at first.
///// Once the number reaches to `-1`,
///// it switches to offset mode in `0..<.max` range.
///// Offset mode uses automatically compressing shared array slot,
///// and offset number gets updated.
///// Using this is very slow, but let the app continue
///// to work without worrying about running out of key-space.
///// by compressing unused key-space.
///// And then, key count is only limited by amount of memory.
//final class IRTPIdentity {
//    var number = Int.min
//}
