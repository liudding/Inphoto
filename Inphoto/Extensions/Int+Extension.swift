//
//  Int+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/12/3.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

extension Int {
    var fileSize: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB, .useKB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(self))
    }
}
