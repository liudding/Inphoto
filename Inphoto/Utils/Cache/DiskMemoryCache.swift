//
//  DiskMemoryCache.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

class DiskMemoryCache<K: Keyable, V: Transformer>: CacheProtocol {
    
    let memoryCache: MemoryCache<K, V>
    let diskCache: DiskCache<K, V>
    
    init() throws {
        memoryCache = MemoryCache<K, V>()
        try diskCache = DiskCache<K, V>()
    }
    
    
    func set(_ value: V, for key: K) throws {
        try memoryCache.set(value, for: key)
        try diskCache.set(value, for: key)
    }
    
    func get(for key: K) throws -> V? {
        if let v = try memoryCache.get(for: key) {
            return v
        }
        
        let value = try diskCache.get(for: key)
        if let v = value {
            try? memoryCache.set(v, for: key)
        }
        
        return value
    }
    
    func remove(for key: K) throws {
        try memoryCache.remove(for: key)
        try diskCache.remove(for: key)
    }
    
    func removeAll() throws {
        try memoryCache.removeAll()
        try diskCache.removeAll()
    }
    
}
