//
//  CleanTemp.swift
//  Inphoto
//
//  Created by liuding on 2018/12/3.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation

class CleanTemp {
    class func cleanAll() {
        let allfiles = FileManager.default.subpaths(atPath: NSTemporaryDirectory())
        for file in allfiles!{
            try! FileManager.default.removeItem(atPath: file)
        }
    }
    
    class func cleanFile(_ file: String) {
        try! FileManager.default.removeItem(atPath: file)
    }
}
