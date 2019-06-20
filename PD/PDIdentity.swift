//
//  PDIdentity.swift
//  PersistentDatastructure
//
//  Created by Henry on 2019/06/18.
//

struct PDIdentity: Hashable, Comparable {
    private var mk = PDSVMarker()

    init() {}
    mutating func revise() {
        mk = PDSVMarker()
    }

    func hash(into hasher: inout Hasher) {
        let oid = ObjectIdentifier(mk)
        hasher.combine(oid)
    }
    static func ==(_ a: PDIdentity, _ b: PDIdentity) -> Bool {
        return a.mk === b.mk
    }
    static func <(_ a: PDIdentity, _ b: PDIdentity) -> Bool {
        return ObjectIdentifier(a.mk) < ObjectIdentifier(b.mk)
    }
}

private final class PDSVMarker {}

