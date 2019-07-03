//
//  Import.swift
//  PD
//
//  Created by Henry on 2019/06/19.
//

import Foundation
import BTree
import Tree

public typealias PDList<E> = List<E>
public typealias PDSet<E> = SortedSet<E> where E:Comparable
public typealias PDMap<K,V> = Map<K,V> where K:Comparable

public typealias PRList<E> = PDListRepository<E>
public typealias PRSortingMapList<K,V> = PDSortingMapListRepository<K,V> where K:Comparable
public typealias PRListTree<E> = PDListTreeRepository<E> 


//public typealias PDSumList<T> = SBTL<T> where T: SBTLValueProtocol
////public typealias PDSumSet<T> = SBTLSet<T> where T: Comparable & SBTLValueProtocol
//public typealias PDSumMap<K,V> = SBTLMap<K,V> where K: Comparable, V: SBTLValueProtocol
//public typealias PDSumProtocol = SBTLValueProtocol

//public typealias PDUnorderedMapTree<Key,Value> = PersistentUnorderedMapTree<Key,Value> where Key: Comparable
//public typealias PDOrderedMapTree<Key,Value> = PersistentOrderedMapTree<Key,Value> where Key: Comparable

@available(*,deprecated: 0)
public typealias PDOrderedMapTree<Key,Value> = PersistentOrderedMapTree<Key,Value> where Key: Comparable
@available(*,deprecated: 0)
public typealias PDOrderedMapTreeProtocol = OrderedMapTreeProtocol

