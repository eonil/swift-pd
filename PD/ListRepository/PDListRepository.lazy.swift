//
//  PDListRepository.lazy.swift
//  PD
//
//  Created by Henry on 2019/06/30.
//

public extension PDListRepository {
    var lazy: Lazy {
        return Lazy(base: self)
    }
    struct Lazy {
        var base: PDListRepository
    }
}
