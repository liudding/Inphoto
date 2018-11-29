//
//  AssetManager.swift
//  Inphoto
//
//  Created by liuding on 2018/11/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation
import Photos

class AssetManager: NSObject {
    
    fileprivate let imageManager = PHCachingImageManager()
    
    func requestImage(_ asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, info) in
            
        }
    }
}
