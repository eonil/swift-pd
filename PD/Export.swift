//
//  Import.swift
//  PD
//
//  Created by Henry on 2019/06/19.
//

import Foundation
import BTree
import SBTL
import Tree

public typealias PDList<T> = List<T>
public typealias PDSet<T> = SortedSet<T> where T: Comparable
public typealias PDMap<K,V> = Map<K,V> where K: Comparable

public typealias PDSumList<T> = SBTL<T> where T: SBTLValueProtocol
//public typealias PDSumSet<T> = SBTLSet<T> where T: Comparable & SBTLValueProtocol
public typealias PDSumMap<K,V> = SBTLMap<K,V> where K: Comparable, V: SBTLValueProtocol
public typealias PDSumProtocol = SBTLValueProtocol

public typealias PDUnorderedMapTree<Key,Value> = PersistentUnorderedMapTree<Key,Value> where Key: Comparable
public typealias PDOrderedMapTree<Key,Value> = PersistentOrderedMapTree<Key,Value> where Key: Comparable
