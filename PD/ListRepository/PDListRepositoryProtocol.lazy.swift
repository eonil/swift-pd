//
//  PDListRepositoryProtocol.lazy.swift
//  PD
//
//  Created by Henry on 2019/07/03.
//

public extension PDListRepositoryProtocol {
    var lazy: Lazy {
        return Lazy(base: self)
    }
    typealias Lazy = PDLazyListRepository<Self>
}
