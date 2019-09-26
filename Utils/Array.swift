//
//  Array+Ext.swift
//  dfdfds
//
//  Created by CP3 on 9/8/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
}

extension Array {
    public func accumulate<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> [Result] {
        var result = initialResult
        return try self.map { element in
            result = try nextPartialResult(result, element)
            return result
        }
    }
    
    public func all(matching predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try !self.contains { try !predicate($0) }
    }
    
    public func none(matching predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try !self.contains { try predicate($0) }
    }
    
    public func any(matching predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try self.contains { try predicate($0) }
    }
    
    public func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        return try self.reduce(0) {
            return $0 + (try predicate($1) ? 1 : 0)
        }
    }
    
    public func indices(where predicate: (Element) throws -> Bool) rethrows -> [Index] {
        return try self.enumerated()
            .filter { try predicate($0.1) }
            .map{ $0.0 }
    }
    
    public func last(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        for element in reversed() where try predicate(element) {
            return element
        }
        return nil
    }
    
    func mapWithReduce<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try reduce([]) {
            $0 + [try transform($1)]
        }
    }
    
    func filterWithReduce(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try reduce([]) {
            try isIncluded($1) ? $0 + [$1] : $0
        }
    }
    
    func accumulateWithReduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> [Result] {
        var result = initialResult
        return try self.reduce([]) {
            result = try nextPartialResult(result, $1)
            return $0 + [result]
        }
    }
}
