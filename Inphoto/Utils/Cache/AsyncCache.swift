//
//  AsyncCache.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

class AsyncCache<K: Keyable, V: Transformer> {
    
    let queue : DispatchQueue
    let diskMemoryCache: DiskMemoryCache<K, V>
    
    init(queue: DispatchQueue) throws {
        self.queue = queue
        diskMemoryCache = try DiskMemoryCache<K, V>()
    }
    
    func set(_ value: V, for key: K, completionHandler: @escaping (Bool, Error?) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.diskMemoryCache.set(value, for: key)
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
            
        }
    }
    
    func get(for key: K, completionHandler: @escaping (V?, Error?) -> Void) {
        queue.async { [weak self] in
            do {
                let v = try self?.diskMemoryCache.get(for: key)
                completionHandler(v, nil)
            } catch {
                completionHandler(nil, error)
            }
            
        }
    }
    
    func remove(for key: K, completionHandler: @escaping (Bool, Error?) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.diskMemoryCache.remove(for: key)
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
            
        }
    }
    
    func removeAll(completionHandler: @escaping (Bool, Error?) -> Void) throws {
        queue.async { [weak self] in
            do {
                try self?.diskMemoryCache.removeAll()
                completionHandler(true, nil)
            } catch {
                completionHandler(false, error)
            }
            
        }
    }
    
    
    
}
