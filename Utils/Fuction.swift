//
//  Fuction.swift
//  Advanced-Swift
//
//  Created by CP3 on 9/18/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

public typealias SortDescriptor<Value> = (Value, Value) -> Bool

public func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    by areInIncreasingOrder: @escaping (Key, Key) -> Bool)
    -> SortDescriptor<Value> {
        return { areInIncreasingOrder(key($0), key($1)) }
}

public func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    ascending: Bool = true)
    -> SortDescriptor<Value> where Key: Comparable {
        return { ascending ? key($0) < key($1) : key($0) > key($1) }
}

public func lift<A>(_ compare: @escaping (A, A) -> Bool)
    -> (A?, A?) -> Bool {
    return{ (lhs, rhs) in
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return false
        case let (l?, r?): return compare(l,r)
        }
    }
}

// MARK: - combine
public func combine<Value>(
    sortDescriptors: [SortDescriptor<Value>])
    -> SortDescriptor<Value> {
    return { lhs, rhs in
        for sort in sortDescriptors {
            if sort(lhs, rhs) { return true }
            if sort(rhs, lhs) { return false }
        }
        
        return false
    }
}

infix operator <||> : LogicalDisjunctionPrecedence
public func <||><A>(lhs: @escaping (A,A) -> Bool, rhs: @escaping (A,A) -> Bool)
    -> (A,A) -> Bool {
    return { l, r in
        if lhs(l, r) { return true }
        if lhs(r, l) { return false }
        if rhs(l, r) { return true }
        return false
    }
}

// MARK:- 支持类似 String.localizedStandardCompare 方法
public func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    ascending: Bool = true,
    by comparator: @escaping (Key) -> (Key) -> ComparisonResult)
    -> SortDescriptor<Value> {
        return { lhs, rhs in
            let order: ComparisonResult = ascending ? .orderedAscending : .orderedDescending
            return comparator(key(lhs))(key(rhs)) == order
        }
}

func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult)
    -> (A?) -> (A?) -> ComparisonResult
{
    return { lhs in
        { rhs in
            switch (lhs, rhs) {
            case (nil, nil): return .orderedSame
            case (nil, _): return .orderedAscending
            case (_, nil): return .orderedDescending
            case let (l?, r?): return compare(l)(r)
            }
        }
    }
}

// MARK: - Keypath
public func sortDescriptor<Value, Key>(
    keyPath: KeyPath<Value, Key>,
    by areInIncreasingOrder: @escaping (Key, Key) -> Bool)
    -> SortDescriptor<Value> {
        return { areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) }
}

public func sortDescriptor<Value, Key>(
    keyPath: KeyPath<Value, Key>,
    ascending: Bool = true)
    -> SortDescriptor<Value> where Key: Comparable {
        return { ascending ? $0[keyPath: keyPath] < $1[keyPath: keyPath] : $0[keyPath: keyPath] > $1[keyPath: keyPath] }
}
