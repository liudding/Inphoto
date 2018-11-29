//
//  Dictionary+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/10/24.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

infix operator ++

extension Dictionary {
    func toArray() -> [[String: Any]] {
        var array: [[String: Any]] = []
        for (key, value) in self{
            array.append(["\(key)": value])
        }
        
        return array
    }
    
    public subscript(path path: [Key]) -> Any? {
        get {
            guard !path.isEmpty else { return nil }
            var result: Any? = self
            for key in path {
                if let element = (result as? [Key: Any])?[key] {
                    result = element
                } else {
                    return nil
                }
            }
            return result
        }
        set {
            if let first = path.first {
                if path.count == 1, let new = newValue as? Value {
                    return self[first] = new
                }
                if var nested = self[first] as? [Key: Any] {
                    nested[path: Array(path.dropFirst())] = newValue
                    return self[first] = nested as? Value
                }
            }
        }
    }
    
    static func + (left: [Key: Value], right: [Key: Value]) -> [Key: Value] {
        var result = left
        right.forEach { result[$0] = $1 }
        return result
    }
    
    static func += (left: inout [Key: Value], right: [Key: Value]) {
        right.forEach { left[$0] = $1 }
    }
    
//    static func combine(left: [Key: Value], right: [Key: Value]) -> [Key: Value] {
//        var result = left
//        right.forEach { (key, value) in
//            
//            if result.keys.contains(key), let dictValue = value as? Dictionary, let resultValue = result[key] as? Dictionary {
//                result[key] = Dictionary.combine(left: resultValue, right: dictValue)
//            } else {
//                result[key] = value
//            }
//        }
//
//        return result
//    }
    
    
    static func ++ (left: [Key: Value], right: [Key: Value]) -> [Key: Value] {
        var result = left
        right.forEach { (key, value) in
            
            if result.keys.contains(key), let dictValue = value as? Dictionary, let resultValue = result[key] as? Dictionary {
                result[key] = (resultValue ++ dictValue) as? Value
            } else {
                result[key] = value
            }
        }
        
        return result
    }
}
