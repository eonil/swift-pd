////
////  PDListRepository.flatten.swift
////  PD
////
////  Created by Henry on 2019/06/30.
////
//
//import Foundation
//
//public extension PDListRepository where Value: PDListTreeElementProtocol {
//    func flatten() -> PDTimeline<Step> {
//
//    }
//    /// Flatten list-tree repository.
//    /// This is specialized repository that flattens nested list repositories.
//    /// Nested list repositories can be converted into single list-tree repository,
//    /// but not directly due to timeline discontinuity.
//    /// Timlines of nested list repositories are split and recorded individually,
//    /// therefore, it's impossible to combine them into single timeline.
//    /// Here we need some "glue" stepping that can make artifitial continuity.
//    /// We
//    struct Flatten: PDRepositoryProtocol {
//        var impl
//    }
//}
//protocol PDListTreeElementProtocol {
//    var subrepository: PDListRepository<Self> { get }
//}
//
