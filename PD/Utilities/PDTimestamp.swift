//
//  PDTimestamp.swift
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
public struct PDTimestamp:
Equatable,
CustomReflectable {
    private let refID = PDRefID()
    public init() {}
    public static func == (_ a: PDTimestamp, _ b: PDTimestamp) -> Bool {
        return a.refID === b.refID
    }
    public var customMirror: Mirror {
        return Mirror(self, children: [])
    }
}


#if DEBUG
extension PDTimestamp: CustomStringConvertible {
    public var description: String {
        return "PDTimestamp:#\(refID.num)"
    }
}
extension PDTimestamp: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

private final class PDRefID {
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
private final class PDRefID {}
#endif

