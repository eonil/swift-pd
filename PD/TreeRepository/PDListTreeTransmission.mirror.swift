//
//  PDListTreeTransmission.mirror.swift
//  PD
//
//  Created by Henry on 2019/07/01.
//

import Tree
public extension PDListTreeTransmission {
    var customMirror: Mirror {
        return Mirror(self, children: [
            "timestampTree": timestampTree,
            ])
    }
}
