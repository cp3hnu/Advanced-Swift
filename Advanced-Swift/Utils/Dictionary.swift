//
//  File.swift
//  Utils
//
//  Created by CP3 on 9/19/19.
//  Copyright © 2019 CP3. All rights reserved.
//

import Foundation

extension Dictionary {
    /*
     设置返回值的类型，使得更改操作可以直接在顶层字典变量中进行，例如
     dict["coordinates", as: [String: Double].self]?["latitude"] = 36.0
    */
    subscript<Result>(key: Key, as type: Result.Type) -> Result? {
        get {
            return self[key] as? Result
        } set {
            guard let value = newValue as? Value else { return }
            self[key] = value
        }
    }
}
