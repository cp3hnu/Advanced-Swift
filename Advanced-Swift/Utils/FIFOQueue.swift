//
//  FIFOQueue.swift
//  dfdfds
//
//  Created by CP3 on 9/9/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

/// ⼀一个能够将元素⼊入队和出队的类型
protocol Queue {
    /// 在 `self` 中所持有的元素的类型
    associatedtype Element
    /// 将 `newElement` ⼊入队到 `self`
    mutating func enqueue(_ newElement: Element) /// 从 `self` 出队⼀一个元素
    mutating func dequeue() -> Element?
}

/// ⼀一个⾼高效的 FIFO 队列列，其中元素类型为 `Element`
struct FIFOQueue<Element>: Queue {
    private var left: [Element] = []
    private var right: [Element] = []
    
    /// 将元素添加到队列列最后
    /// - 复杂度: O(1)
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }
    
    /// 从队列列前端移除⼀一个元素
    /// 当队列列为空时，返回 nil
    /// - 复杂度: 平摊 O(1)
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}

extension FIFOQueue: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}

extension FIFOQueue: Collection, MutableCollection  {
    typealias Indices = CountableRange<Int>
    var indices: CountableRange<Int> {
        return startIndex..<endIndex }
    
    public var startIndex: Int {
        return 0
    }
    public var endIndex: Int {
        return left.count + right.count
    }
    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                return left[left.count - position - 1]
            } else {
                return right[position - left.count]
            }
        }
        set {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                left[left.count - position - 1] = newValue
            } else {
                return right[position - left.count] = newValue
            }
        }
    }
}

extension FIFOQueue: BidirectionalCollection {
    func index(before i: Int) -> Int {
        precondition(i > startIndex)
        return i - 1
    }
}

extension FIFOQueue: RandomAccessCollection {}

extension FIFOQueue: RangeReplaceableCollection {
    mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C) where C.Element == Element {
        right = left.reversed() + right
        left.removeAll()
        right.replaceSubrange(subrange, with: newElements)
    }
}
