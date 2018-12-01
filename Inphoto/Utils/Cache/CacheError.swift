//
//  Error.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

public enum CacheError: Error {
    case notFound
    case invalidType
    case diskCacheFailed
}
