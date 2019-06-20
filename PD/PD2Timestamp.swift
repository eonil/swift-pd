//
//  PD2Timestamp.swift
//  PD
//
//  Created by Henry on 2019/06/20.
//

import Foundation

/// A timestamp with conceptually infinite resolution.
///
/// This incorporates concept of "infinite resolution clock".
/// Conceptually, this type keeps its creation time and resolution of the time
/// clock is infinite. Therefore, every instance of this type
/// are globally unique.
///
/// Though this is a timestamp, you cannot perform comparison
/// on this value. The time value is hidden for easiler implementation.
///
public struct PD2Timestamp: Equatable {
    private let refID = PD2RefID()
    public static func == (_ a: PD2Timestamp, _ b: PD2Timestamp) -> Bool {
        return a.refID === b.refID
    }
}


#if DEBUG
extension PD2Timestamp: CustomStringConvertible {
    public var description: String {
        return "T:\(refID.num)"
    }
}
extension PD2Timestamp: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

private final class PD2RefID {
    let num = {
        let n: Int
        exck.lock()
        seed += 1
        n = seed
        exck.unlock()
        return n
        }() as Int
}
private var seed = 0
private let exck = NSLock()

#else
private final class PD2RefID {}
#endif
