//
//  PDListTreeRepository.mirror.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

public extension PDListTreeRepository {
    var customMirror: Mirror {
        return Mirror(self, children: [
            "timeline": timeline])
    }
}
