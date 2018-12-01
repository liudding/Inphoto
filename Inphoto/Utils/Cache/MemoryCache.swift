//
//  MemoryCache.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

class MemoryCache<K: Keyable, V>: CacheProtocol {
    
    fileprivate let cache = NSCache<NSString, MemoryCacheObject>()
    
    func set(_ value: V, for key: K) throws {
        let v = MemoryCacheObject(value: value)
        cache.setObject(v, forKey: NSString(string: key.toString()))
    }
    
    func get(for key: K) throws -> V? {
        guard let memoryObject =  cache.object(forKey: NSString(string: key.toString())) else {
            return nil
        }
        guard let v = memoryObject.value as? V else {
            throw CacheError.invalidType
        }
        
        return v
    }
    
    func remove(for key: K) throws {
        cache.removeObject(forKey: NSString(string: key.toString()))
    }
    
    func removeAll() throws {
        cache.removeAllObjects()
    }
}

class MemoryCacheObject: NSObject {
    let value: Any
    
    init(value: Any) {
        self.value = value
    }
}
