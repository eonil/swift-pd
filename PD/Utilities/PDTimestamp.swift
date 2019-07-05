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
    private let impl = IMPLTimestamp()

    /// Approximated age since a finite time-point.
    func approximatedAge(since d: Date) -> TimeInterval {
        return d.timeIntervalSince(impl.finiteTimePoint)
    }
    func isApproximatelyOlder(than d: Date) -> Bool {
        return impl.finiteTimePoint < d
    }

    public init() {}
    public static func == (_ a: PDTimestamp, _ b: PDTimestamp) -> Bool {
        return a.impl === b.impl
    }
    public var customMirror: Mirror {
        return Mirror(self, children: [])
    }

    static let `default` = PDTimestamp()
}


#if DEBUG
extension PDTimestamp: CustomStringConvertible {
    public var description: String {
        return "PDTimestamp:#\(impl.num)"
    }
}
extension PDTimestamp: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

private final class IMPLTimestamp {
    let finiteTimePoint = Date()
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
private final class IMPLTimestamp {
    let finiteTimePoint = Date()
}
#endif

