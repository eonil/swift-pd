//
//  PDMapTreeProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDMapTreeProtocol {
    associatedtype Key: Comparable
    associatedtype Value
}

extension PDUnorderedMapTree: PDMapTreeProtocol {}
extension PDOrderedMapTree: PDMapTreeProtocol {}
