//
//  PDListStep.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDListStep where
Snapshot: RandomAccessCollection,
Snapshot.Index == Int {
    var lazyStep: Lazy { return Lazy(base: self) }
    struct Lazy { var base: PDListStep }
}
public extension PDListStep.Lazy {
    typealias MapSnapshot<X> = LazyMapCollection<Snapshot,X>
    typealias MapStep<X> = PDListStep<MapSnapshot<X>>
    func map<X>(_ mfx: @escaping (Snapshot.Element) -> X) -> MapStep<X> {
        typealias C = MapSnapshot<X>
        typealias S = PDListStep<C>
        typealias P = S.Point

        let os = base.old.snapshot.lazy.map(mfx)
        let ns = base.new.snapshot.lazy.map(mfx)
        let s = S(
            operation: base.operation,
            range: base.range,
            old: P(time: base.old.time, snapshot: os),
            new: P(time: base.new.time, snapshot: ns))
        return s
    }
}
