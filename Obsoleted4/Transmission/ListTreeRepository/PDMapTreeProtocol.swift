//
//  PDMapTreeProtocol.swift
//  PD
//
//  Created by Henry on 2019/06/25.
//

public protocol PDMapProtocol {
    associatedtype Key: Comparable
    associatedtype Value
}

extension PDOrderedMapTree: PDMapProtocol {}
