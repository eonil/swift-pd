//
//  PDMergingListTransmission.swift
//  PD
//
//  Created by Henry on 2019/07/02.
//

/// A transmission that merges multiple list-repo into single set-list-repo.
///
/// Basically, this makes a merged collection of all source collections and
/// set target to it. And tries best to keep performance best.
///
public struct PDMergingListTransmission {
    private var timestamps = [PDTimestamp?]()
    init(capacity c: Int) {
        timestamps = Array(repeatElement(nil, count: c))
    }
}
public extension PDMergingListTransmission {
    typealias SourceList<K,V> = PDMergingSourceList<K,V> where K:Comparable & Hashable
    typealias Target<K,V> = PDSortingMapListRepository<K,V> where K:Comparable & Hashable

    /// Set `b` to a merged list of all lists in source `a`.
    ///
    /// Basically, this is whole replacement operations, and takes O(n) time.
    ///
    ///     b = merge(a)
    ///
    /// Optimization
    /// ------------
    /// If sources satisfy these rules, complexity can be O(count(diff)).
    /// - All sources are continous to previous transferred sources at same offset in `a`.
    ///
    /// If any source at same offset is discontinuous, this type will perform full
    /// merge to get correct result.
    ///
    /// Uniqueness
    /// ----------
    /// All keys in all sources must be unique.
    /// Duplicated key is not allowed and causes crash.
    /// You need to make sure all keys to be unique before passing sources here.
    ///
    mutating func transfer<C,K,V>(from a:C, to b: inout Target<K,V>) where
    C:RandomAccessCollection,
    C.Element: PDListRepositoryProtocol,
    C.Element.Element == Target<K,V>.Element,
    K:Comparable & Hashable {
        typealias R = C.Element
        typealias E = R.Element
        typealias T = Target<K,V>

        // Check timestamps.
        let c = a.count
        timestamps = timestamps.count == c ? timestamps : Array(repeating: nil, count: c)
        func isContinuous(_ r:R, at i:Int) -> Bool {
            guard let t = timestamps[i] else { return false }
            return r.latest(since: t) != nil
        }
        let areAllContinuous = a.enumerated().map({ i,r in isContinuous(r, at: i) }).reduce(true, { $0 && $1 })

//        // Transfer.
//        if areAllContinuous {
//            // All sources are continuous.
//            // Just replay all insertions and deletions.
////            var
////            var firstRemovings = [K:V]()
////            var midReplacements = [K:V]()
////            var lastInsertions = [K:V]()
//            for (i,r) in a.enumerated() {
//                // Timestamps and suffixes always exist because it's continuous.
//                let t = timestamps[i]!
//                let r1 = r.latest(since: t)!
//                var firstRemovings = [K:V]()
//                var midReplacements = [K:V]()
//                var lastInsertions = [K:V]()
//                for x in r1.timeline.steps {
//                    switch x.operation {
//                    case .remove:
//                        for i in x.range.lazy.reversed() {
//                            let e = x.old.snapshot[i]
//                            let k = e.key
//                            let v = e.value
//                            if lastInsertions[k] != nil {
//                                lastInsertions[k] = nil
//                            }
//                            else {
//                                firstRemovings[k] = v
//                            }
//                        }
//                    case .insert:
//                        for i in x.range.lazy.reversed() {
//                            let e = x.old.snapshot[i]
//                            let k = e.key
//                            let v = e.value
//                            if lastInsertions[k] != nil {
//                                precondition(lastInsertions[kv3.0] == nil, "Determinant mapping function returned duplicated key.")
//                            }
//                            lastInsertions[k] = v
//                        }
//                    case .replace:
//
//                    }
//                }
//            }
//        }
//        else {
            // Source are discontinuous.
            // Make full snapshot replacement steps.
            timestamps = Array(repeating: nil, count: c)
            var s2 = T.Snapshot()
            for (i,r) in a.enumerated() {
                guard let x = r.timeline.steps.last else { continue }
                for e in x.new.snapshot {
                    let k = e.key
                    let v = e.value
                    precondition(s2[k] == nil, "Determinant mapping function returned a duplicated key.")
                    s2[k] = v
                }
            }
            b.recordWholeSnapshotReplacementSteps(s2, with: PDTimestamp())
//        }
    }
}
public extension PDMergingListTransmission {
    /// A easy-to-understand variant.
    mutating func transfer<R,K,V>(from a:[R], to b: inout Target<K,V>) where
    R: PDListRepositoryProtocol,
    R.Element == Target<K,V>.Element,
    K:Comparable & Hashable {
        transfer(from: a, to: &b)
    }
    /// A easy-to-understand variant.
    mutating func transfer<K,V>(from a:[PDAnyListRepository<Target<K,V>.Element>], to b: inout Target<K,V>) where
    K:Comparable & Hashable {
        transfer(from: a, to: &b)
    }
    /// A easy-to-understand variant.
    mutating func transfer<K,V>(from a:PDMergingSourceList<K,V>, to b: inout Target<K,V>) where
    K:Comparable & Hashable {
        transfer(from: a.reps, to: &b)
    }
}

/// A helper type to make using `PDMergingListTransmission` easier.
public struct PDMergingSourceList<K,V> where
K:Comparable & Hashable {
    fileprivate private(set) var reps = [PDAnyListRepository<Element>]()
    public typealias Element = PDSortingMapListRepository<K,V>.Element
    public mutating func append<R>(_ r:R) where
    R:PDListRepositoryProtocol,
    R.Element == Element {
        reps.append(PDAnyListRepository(r))
    }
}

