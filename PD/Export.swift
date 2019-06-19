//
//  Import.swift
//  PD
//
//  Created by Henry on 2019/06/19.
//

import Foundation
import SBTL

public typealias PDList<T> = BTL<T>
public typealias PDSet<T> = BTLSet<T> where T: Comparable
public typealias PDMap<K,V> = BTLMap<K,V> where K: Comparable

public typealias PDSumList<T> = SBTL<T> where T: SBTLValueProtocol
public typealias PDSumSet<T> = SBTLSet<T> where T: Comparable & SBTLValueProtocol
public typealias PDSumMap<K,V> = SBTLMap<K,V> where K: Comparable, V: SBTLValueProtocol
public typealias PDSumProtocol = SBTLValueProtocol
