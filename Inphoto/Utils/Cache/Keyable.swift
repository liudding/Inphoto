//
//  Keyable.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

public protocol Keyable {
    func toString() -> String
}

extension Keyable {
    public func toString() -> String {
        return "\(String(describing: self))"
    }
}

extension String: Keyable {
    public func toString() -> String {
        return self
    }
}


