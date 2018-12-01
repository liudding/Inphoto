//
//  Transformer.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

public protocol Transformer {
    func toData() throws -> Data
    static func fromData(_ data: Data) throws -> Self
}


extension String: Transformer {
    
    public func toData() throws -> Data {
        return self.data(using: .utf8) ?? Data()
    }
    
    public static func fromData(_ data: Data) throws -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension Transformer where Self: Codable {
    
    public func toData() throws -> Data {
        
        return try JSONEncoder().encode(self)
    }
    
    public static func fromData(_ data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
