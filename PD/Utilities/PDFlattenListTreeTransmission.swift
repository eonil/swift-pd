////
////  PDFlattenListTreeTransmission.swift
////  PD
////
////  Created by Henry on 2019/06/30.
////
//
//public struct PDFlattenListTreeTransmission<Element> where
//Element: PDListTreeElementProtocol {
//    public private(set) var source = Source()
//    public private(set) var target = Target()
//}
//public extension PDFlattenListTreeTransmission {
//    typealias Source = PDListRepository<Element>
//    typealias Target = PDListTreeRepository<Element.Value>
//}
//extension PDFlattenListTreeTransmission {
//    func reset(to newRepository: Source) {
//        for e in newRepository {
//            let a = source.lazyRepository.map({ $0.lazy.map({ "\($0)" }) })
//            a
//        }
//    }
//}
//public extension PDFlattenListTreeTransmission {
//    /// Replays new state of a list
//    mutating func replay(_ newRepository: Source) {
//        guard let latestTimestamp = source.timeline.steps.last?.new.time else {
//            reset(to: newRepository)
//            return
//        }
//        guard let newTimeline = newRepository.timeline.suffix(since: latestTimestamp) else {
//            fatalError("There's no intersection point therefore the new Repository cannot be replayed.")
//        }
//        for x in newTimeline.steps {
//            switch x.operation {
//            case .remove:
//
//            case .insert:
//            case .replace
//            }
//        }
//    }
//}
//
