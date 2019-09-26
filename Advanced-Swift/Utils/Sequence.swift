//
//  Sequence.swift
//  dfdfds
//
//  Created by CP3 on 9/9/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

struct FibsIterator: IteratorProtocol {
    var state = (0, 1)
    mutating func next() -> Int? {
        let upcomingNumber = state.0
        state = (state.1, state.0 + state.1)
        return upcomingNumber
    }
}

struct FibsSequence: Sequence {
    func makeIterator() -> FibsIterator {
        return FibsIterator()
    }
}

struct PrefixIterator: IteratorProtocol {
    let string: String
    var offset: String.Index
    init(string: String) {
        self.string = string
        offset = string.startIndex
    }
    mutating func next() -> Substring? {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        return string[..<offset]
    }
}

struct PrefixSequence: Sequence {
    let string: String
    func makeIterator() -> PrefixIterator {
        return PrefixIterator(string: string)
    }
}

// 泛型前缀迭代器
struct PrefixIterator2<Base: Collection>: IteratorProtocol, Sequence {
    let base: Base
    var offset: Base.Index
    init(_ base: Base) {
        self.base = base
        self.offset = base.startIndex
    }
    
    mutating func next() -> Base.SubSequence? {
        guard offset != base.endIndex else { return nil }
        base.formIndex(after: &offset)
        return base.prefix(upTo: offset)
    }
}
