//
//  CacheProtocol.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

public protocol CacheProtocol {
    associatedtype K
    associatedtype V
    
    func set(_ value: V, for key: K) throws
    
    func get(for key: K) throws -> V?
    
    func remove(for key: K) throws
    
    func removeAll() throws
}
