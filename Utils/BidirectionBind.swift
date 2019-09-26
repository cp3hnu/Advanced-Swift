//
//  BidirectionBind.swift
//  Advanced-Swift
//
//  Created by CP3 on 9/19/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

extension NSObjectProtocol where Self: NSObject {
    func observe<A, Other>(_ keyPath: KeyPath<Self, A>,
                           writeTo other: Other,
                           _ otherKeyPath: ReferenceWritableKeyPath<Other, A>)
        -> NSKeyValueObservation where A: Equatable, Other: NSObjectProtocol {
            return observe(keyPath, options: .new) { _, change in
                guard let newValue = change.newValue,
                    other[keyPath: otherKeyPath] != newValue else { return }
                
                other[keyPath: otherKeyPath] = newValue
            }
        }
    
    public func bind<A, Other>(_ keyPath: ReferenceWritableKeyPath<Self,A>,
                        to other: Other,
                        _ otherKeyPath: ReferenceWritableKeyPath<Other,A>)
        -> (NSKeyValueObservation, NSKeyValueObservation) where A: Equatable, Other: NSObject {
            let one = observe(keyPath, writeTo: other, otherKeyPath)
            let two = other.observe(otherKeyPath, writeTo: self, keyPath)
            return (one,two)
    }
}
