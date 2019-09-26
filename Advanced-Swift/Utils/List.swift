//
//  List.swift
//  dfdfds
//
//  Created by CP3 on 9/9/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

enum List<Element> {
    case end
    indirect case node(Element, next: List<Element>)
}

extension List {
    /// 在链表前⽅方添加⼀一个值为 `x` 的节点，并返回这个链表
    func cons(_ x: Element) -> List {
        return .node(x, next: self)
    }
}

extension List: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self = elements.reversed().reduce(.end) { partialList, element in
            partialList.cons(element)
        }
    }
}

extension List {
    mutating func push(_ x: Element) {
        self = self.cons(x)
    }
    
    mutating func pop() -> Element? {
        switch self {
            case .end: return nil
            case let .node(x, next: tail):
                self = tail
                return x
        }
    }
}

extension List: IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return pop()
    }
}
