//
//  PDX.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

import Foundation

struct PDX<A> where
A: PDListRepositoryProtocol,
A.Element: PDXElementProtocol,
A.Element.Repository == A {
    private(set) var source: A
    private(set) var target: B

    typealias B = PDListTreeRepository<A.Element.Value>
    init(source a:A, target b:B) {
        source = a
        target = b
    }
    mutating func replay(_ r:A, in pp:IndexPath) {
        guard let l = findNewSteps(r) else { return }
        for x in l.steps {
            switch x.operation {
            case .remove:
                for i in x.range.reversed() {
                    let p = pp.appending(i)
                    source.remove(at: i)
                    target.remove(at: p)
                }
            case .insert:
                for i in x.range {
                    let e = x.new.snapshot[i]
                    source.insert(e, at: i)
                    insertRecursively(r, at: i, in: pp)
                }
            case .replace:
                for i in x.range {
                    let e = x.new.snapshot[i]
                    let v = e.value
                    let r = e.subrepositoy
                    let p = pp.appending(i)
                    replay(r, in: p)
                    target.setValue(v, at: p)
                }
            }
        }
    }

    private func findNewSteps(_ r:A) -> A.Timeline? {
        guard let t = source.timeline.steps.last?.new.time else { return r.timeline }
        return r.timeline.suffix(since: t)
    }
    private mutating func insertRecursively(_ r:A, at i:Int, in pp:IndexPath) {
        let e = r[i]
        let v = e.value
        let r1 = e.subrepositoy

        let p = pp.appending(i)
        target.insert(v, at: p)
        for i in 0..<r1.count {
            insertRecursively(r1, at: i, in: p)
        }
    }
}

struct PDXElement<V> {
    var value: V
    var subrepository: PDListRepository<PDXElement>
}
protocol PDXElementProtocol {
    var value: Value { get }
    associatedtype Value
    var subrepositoy: Repository { get }
    associatedtype Repository
}

//protocol PDNestingListRepositoryProtocol: PDListRepositoryProtocol where
//Element: PDXElementProtocol,
//Element.Repository == Self {
//
//}
