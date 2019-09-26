//
//  Generic.swift
//  Utils
//
//  Created by CP3 on 9/24/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

// MARK: - 子集
extension Sequence where Element: Equatable {
    /// 当且仅当 `self` 中的所有元素都包含在 `other` 中，返回 true，O(n * m)
    public func isSubset<S: Sequence>(of other: S) -> Bool where S.Element == Element {
        for element in self {
            guard other.contains(element) else {
                return false
            }
        }
        
        return true
    }
}

/*
 Swift 在重载上非常灵活，你不仅能通过输入类型或者返回类型来重载，你也可以通过泛型占位符的不同约束来重载。
 类型检查器会使用它所能找到的最精确的重载。这里 isSubset 的两个版本都是泛型函数，所以非泛型函数先于泛型函数的规则并不适用。
 不过因为 Hashable 是对 Equatable 的扩展，所以要求 Hashable 的版本更加精确。
 */
extension Sequence where Element: Hashable {
    /// 如果 `self` 中的所有元素都包含在 `other` 中，则返回 true，O(n + m)
    public func isSubset<S: Sequence>(of other: S) -> Bool where S.Element == Element {
        let otherSet = Set(other)
        for element in self {
            guard otherSet.contains(element) else { return false }
        }
        
        return true
    }
}

extension Sequence {
    /// 对不满足Equatable的Sequence，重载函数
    public func isSubset<S: Sequence>(of other: S,
                               by areEquivalent: (Element, S.Element) -> Bool)
        -> Bool {
            for element in self {
                guard other.contains(where: { areEquivalent(element, $0) }) else {
                    return false
                }
            }
            return true
    }
}


// MARK: - 二分查找
extension RandomAccessCollection {
    public func binarySearch(for value: Element,
                             areInIncreasingOrder: (Element, Element) -> Bool)
        -> Index? {
            guard !isEmpty else { return nil }
            var left = startIndex
            var right = index(before: endIndex)
            while left <= right {
                let dist = distance(from: left, to: right)
                let mid = index(left, offsetBy: dist/2)
                let candidate = self[mid]
                if areInIncreasingOrder(candidate, value) {
                    left = index(after: mid)
                } else if areInIncreasingOrder(value, candidate) {
                    right = index(before: mid)
                }
                else {
                    // 由于 isOrderedBefore 的要求，如果两个元素互⽆无顺序关系，那么它们⼀一定相等
                    return mid
                }
            }
            // 未找到
            return nil
    }
}

extension RandomAccessCollection where Element: Comparable {
    public func binarySearch(for value: Element) -> Index? {
        return binarySearch(for: value, areInIncreasingOrder: <)
    }
}
