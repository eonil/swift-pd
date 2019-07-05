//
//  PDMagic.swift
//  PD
//
//  Created by Henry on 2019/07/05.
//

import Foundation

/// Access to magical feature.
///
/// Magic controls rules under physical/logical layer.
/// This makes global side effects. You have to be aware of what
/// will happen.
public struct PDMagic {
    public static var global = PDMagic()

    /// Steps (except latest step) with both points are older than this date
    /// will be removed from timeline on next recoding.
    public var expirationDate = Date.distantFuture

    /// Steps (except latest step) with both points are older than this interval
    /// will be removed from timeline on next recoding.
    public var expirationInterval = TimeInterval.greatestFiniteMagnitude
}
