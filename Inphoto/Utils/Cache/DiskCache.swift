//
//  DiskCache.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

class DiskCache<K: Keyable, V: Transformer>: CacheProtocol {
    
    fileprivate let fileManager = FileManager.default
    fileprivate let cachePath: String
    
    
    init(path: String = "DiskCache") throws {
        let cacheDir = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        cachePath = cacheDir.appendingPathComponent(path, isDirectory: true).path
        try createDirectory(path: cachePath)
    }
    
    func set(_ value: V, for key: K) throws {
        let path = pathForKey(key)
        
        let data = try value.toData()
        
        guard fileManager.createFile(atPath: path, contents: data, attributes: nil) else {
            throw CacheError.diskCacheFailed
        }
    }
    
    func get(for key: K) throws -> V? {
        let path = pathForKey(key)
        
        guard let data = fileManager.contents(atPath: path) else {
            return nil
        }
        let value = try V.self.fromData(data)
        return value
    }
    
    func remove(for key: K) throws {
        let path = pathForKey(key)
        try fileManager.removeItem(atPath: path)
    }
    
    func removeAll() throws {
        try fileManager.removeItem(atPath: cachePath)
        try createDirectory(path: cachePath)
    }
}

extension DiskCache {
    fileprivate func createDirectory(path: String) throws {
        if fileManager.fileExists(atPath: path) {
            return
        }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                        attributes: nil)
    }
    
    fileprivate func pathForKey(_ key: K) -> String {
        let path = (cachePath as NSString).appendingPathComponent(key.toString().md5String())
        return path
    }
}
