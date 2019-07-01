//
//  PDListStep.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDListStep {
    /// Makes a lazily-evaluated list-step.
    var lazyStep: Lazy { return Lazy(base: self) }
    struct Lazy { var base: PDListStep }
}
public extension PDListStep.Lazy {
    @available(*, deprecated: 0)
    typealias MapSnapshot<X> = LazyMapCollection<PDListStep.Snapshot,X>
    @available(*, deprecated: 0)
    typealias MapStep<X> = PDListStep<MapSnapshot<X>>
    /// Makes a lazy-mapping list-step.
    /// - Warning:
    ///     This is not really lazy and has been deprecated.
    @available(*, deprecated: 0)
    func map<X>(_ mfx: @escaping (PDListStep.Snapshot.Element) -> X) -> MapStep<X> {
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
