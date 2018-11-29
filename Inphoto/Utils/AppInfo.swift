//
//  AppInfo.swift
//  Jice
//
//  Created by liuding on 2018/8/17.
//  Copyright © 2018 fivebytes. All rights reserved.
//

import Foundation

struct AppInfo {
    
    static let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    
    static var appName: String {
        get {
            return displayName ?? name ?? ""
        }
    }
    
    static let buildVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
}




